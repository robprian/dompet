import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/data/detection_notification_service.dart';
import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/i_detection_repository.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_settings_notifier.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeDetectionRepository implements IDetectionRepository {
  final List<TransactionDetectionModel> stored = [];
  final Map<String, String> settings = {};
  final List<({String id, DetectionStatus status, String? accountId, String? categoryId})> resolutions = [];
  final List<({String merchant, String categoryId})> learned = [];

  @override
  Stream<List<TransactionDetectionModel>> watchPending() =>
      Stream.value(stored.where((m) => m.status == DetectionStatus.pending).toList());

  @override
  Future<int> countPending() async => stored.where((m) => m.status == DetectionStatus.pending).length;

  @override
  Future<void> saveCandidate(TransactionDetectionModel model) async {
    stored.add(model);
  }

  @override
  Future<bool> hasFingerprint(String fingerprint) async => stored.any((m) => m.fingerprint == fingerprint);

  @override
  Future<bool> hasRecentSimilar({
    required String sourcePackage,
    required int amount,
    required DetectionTransactionType type,
    required String? merchant,
    required String? counterparty,
    required DateTime since,
  }) async => false;

  @override
  Future<void> resolveCandidate({
    required String id,
    required DetectionStatus status,
    String? accountId,
    String? categoryId,
  }) async {
    resolutions.add((id: id, status: status, accountId: accountId, categoryId: categoryId));
    final index = stored.indexWhere((m) => m.id == id);
    if (index >= 0) stored[index] = stored[index].copyWith(status: status);
  }

  @override
  Future<void> learnMerchantCategory({required String merchant, required String categoryId}) async {
    learned.add((merchant: merchant, categoryId: categoryId));
  }

  @override
  Future<String?> getLearnedCategory(String merchant) async => null;

  @override
  Future<void> recordSalary({required int amount, required int dayOfMonth, required double confidence}) async {}

  @override
  Future<bool> hasSalaryRecord() async => false;

  @override
  Future<String?> getSetting(String key) async => settings[key];

  @override
  Future<void> setSetting(String key, String value) async {
    settings[key] = value;
  }
}

class MockTransactionRepository extends Mock implements ITransactionRepository {}

class MockNotificationBridge extends Mock implements NotificationBridge {}

class MockImportService extends Mock implements DetectionImportService {}

class FakeTransactionModel extends Fake implements TransactionModel {}

TransactionDetectionModel detection({String id = 'd1'}) {
  final now = DateTime.utc(2026, 3, 15, 10, 30);
  return TransactionDetectionModel(
    id: id,
    fingerprint: 'fp-$id',
    sourcePackage: 'com.bank.app',
    type: DetectionTransactionType.expense,
    amount: 25000,
    confidence: 0.9,
    confidenceTier: ConfidenceTier.high,
    method: PaymentMethod.qris,
    parserVersion: 'qris-v1',
    status: DetectionStatus.pending,
    occurredAt: now,
    createdAt: now,
    merchant: 'KOPI ABC',
    referenceId: 'REF123',
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
  });

  group('DetectionReviewNotifier', () {
    test('importAsTransaction creates a ledger entry and resolves the candidate', () async {
      final detectionRepo = FakeDetectionRepository()..stored.add(detection());
      final transactionRepo = MockTransactionRepository();
      TransactionModel? created;
      when(() => transactionRepo.createTransaction(any())).thenAnswer((invocation) async {
        created = invocation.positionalArguments.first as TransactionModel;
        return const Success(null);
      });

      final container = ProviderContainer(
        overrides: [
          detectionRepositoryProvider.overrideWithValue(detectionRepo),
          transactionRepositoryProvider.overrideWithValue(transactionRepo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(detectionReviewProvider.notifier)
          .importAsTransaction(
            detection(),
            accountId: 'acc-1',
            categoryId: 'cat-1',
          );

      expect(created, isNotNull);
      expect(created!.amount, 25000);
      expect(created!.accountId, 'acc-1');
      expect(created!.items.first.categoryId, 'cat-1');
      expect(detectionRepo.resolutions.single.status, DetectionStatus.imported);
      expect(detectionRepo.learned.single, (merchant: 'KOPI ABC', categoryId: 'cat-1'));
    });

    test('ignore marks the candidate as ignored', () async {
      final detectionRepo = FakeDetectionRepository()..stored.add(detection());
      final container = ProviderContainer(
        overrides: [detectionRepositoryProvider.overrideWithValue(detectionRepo)],
      );
      addTearDown(container.dispose);

      await container.read(detectionReviewProvider.notifier).ignore(detection());
      expect(detectionRepo.resolutions.single.status, DetectionStatus.ignored);
    });

    test('pending count stream reflects stored candidates', () async {
      final detectionRepo = FakeDetectionRepository()..stored.add(detection());
      final container = ProviderContainer(
        overrides: [detectionRepositoryProvider.overrideWithValue(detectionRepo)],
      );
      final subscription = container.listen(pendingDetectionCountProvider, (previous, next) {});
      addTearDown(() {
        subscription.close();
        container.dispose();
      });

      expect(await container.read(pendingDetectionCountProvider.future), 1);
    });
  });

  group('DetectionSettingsNotifier', () {
    test('loads defaults and persists toggles', () async {
      final detectionRepo = FakeDetectionRepository();
      final bridge = MockNotificationBridge();
      when(bridge.isListenerEnabled).thenAnswer((_) async => false);
      final container = ProviderContainer(
        overrides: [
          detectionRepositoryProvider.overrideWithValue(detectionRepo),
          detectionNotificationServiceProvider.overrideWithValue(
            DetectionNotificationService(bridge: bridge, importService: MockImportService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(detectionSettingsProvider.future);
      expect(initial.enabled, isTrue);
      expect(initial.autoImportThreshold, 0.9);
      expect(initial.accessEnabled, isFalse);

      await container.read(detectionSettingsProvider.notifier).setEnabled(value: false);
      expect(detectionRepo.settings['detectionEnabled'], 'false');

      await container.read(detectionSettingsProvider.notifier).setAutoImportThreshold(value: 0.8);
      expect(detectionRepo.settings['detectionAutoImportThreshold'], '0.8');
    });
  });
}
