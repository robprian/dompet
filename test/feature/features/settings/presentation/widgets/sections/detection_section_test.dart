import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/features/detection/data/detection_notification_service.dart';
import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/domain/i_detection_repository.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_settings_notifier.dart';
import 'package:dompet/features/settings/presentation/widgets/sections/detection_section.dart';
import 'package:dompet/features/settings/presentation/widgets/sections/detection_settings_sheet.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mocktail/mocktail.dart';

class FakeDetectionRepository implements IDetectionRepository {
  final Map<String, String> settings = {};

  @override
  Stream<List<TransactionDetectionModel>> watchPending() => Stream.value(const []);

  @override
  Future<int> countPending() async => 0;

  @override
  Future<void> saveCandidate(TransactionDetectionModel model) async {}

  @override
  Future<bool> hasFingerprint(String fingerprint) async => false;

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
  }) async {}

  @override
  Future<void> learnMerchantCategory({required String merchant, required String categoryId}) async {}

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

class MockNotificationBridge extends Mock implements NotificationBridge {}

class MockImportService extends Mock implements DetectionImportService {}

Widget buildTestableWidget(Widget child, FakeDetectionRepository repo) {
  final bridge = MockNotificationBridge();
  when(bridge.isListenerEnabled).thenAnswer((_) async => false);
  return TranslationProvider(
    child: ProviderScope(
      overrides: [
        detectionRepositoryProvider.overrideWithValue(repo),
        detectionNotificationServiceProvider.overrideWithValue(
          DetectionNotificationService(bridge: bridge, importService: MockImportService()),
        ),
        pendingDetectionCountProvider.overrideWith((ref) => Stream.value(1)),
      ],
      child: MaterialApp(
        builder: (context, child) => FTheme(data: lightTheme, child: child!),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocale(AppLocale.en);

  testWidgets('detection section renders advisor and detection entries', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const DetectionSection(), FakeDetectionRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Dompet Advisor'), findsOneWidget);
    expect(find.text('Transactions to review'), findsOneWidget);
    expect(find.text('Notification access'), findsOneWidget);
    expect(find.text('Enable notification detection'), findsOneWidget);
    expect(find.text('Auto-import high confidence'), findsOneWidget);
    expect(find.text('Auto-import threshold'), findsOneWidget);
  });

  testWidgets('toggling detection persists the setting', (tester) async {
    final repo = FakeDetectionRepository();
    await tester.pumpWidget(buildTestableWidget(const DetectionSection(), repo));
    await tester.pumpAndSettle();

    final switches = find.byType(FSwitch);
    expect(switches, findsNWidgets(3));
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    expect(repo.settings['detectionEnabled'], 'false');
  });

  testWidgets('threshold sheet persists the selected preset', (tester) async {
    final repo = FakeDetectionRepository();
    await tester.pumpWidget(
      buildTestableWidget(
        Builder(
          builder: (context) => FButton(
            onPress: () => DetectionThresholdSheet.show(context, 0.9),
            child: const Text('Show'),
          ),
        ),
        repo,
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('80%'));
    await tester.pumpAndSettle();

    expect(repo.settings['detectionAutoImportThreshold'], '0.8');
  });
}
