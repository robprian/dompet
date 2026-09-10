import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/detection/data/detection_repository.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late DetectionRepository repo;

  final now = DateTime.now().toUtc();

  TransactionDetectionModel model(String id, {DetectionStatus status = DetectionStatus.pending}) {
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
      status: status,
      occurredAt: now,
      createdAt: now,
      merchant: 'KOPI ABC',
    );
  }

  setUp(() {
    db = AppDatabase(connection: NativeDatabase.memory());
    repo = DetectionRepository(db.detectionDao, db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saves and watches pending candidates', () async {
    await repo.saveCandidate(model('d1'));
    await repo.saveCandidate(model('d2', status: DetectionStatus.imported));

    final pending = await repo.watchPending().first;
    expect(pending.map((m) => m.id), ['d1']);
    expect(pending.first.merchant, 'KOPI ABC');
    expect(pending.first.methodLabel, 'QRIS');
    expect(await repo.countPending(), 1);
  });

  test('detects recorded fingerprints', () async {
    expect(await repo.hasFingerprint('fp-d1'), isFalse);
    await repo.saveCandidate(model('d1'));
    expect(await repo.hasFingerprint('fp-d1'), isTrue);
  });

  test('rejects near-duplicate candidates', () async {
    await repo.saveCandidate(model('d1'));
    expect(
      await repo.hasRecentSimilar(
        sourcePackage: 'com.bank.app',
        amount: 25000,
        type: DetectionTransactionType.expense,
        merchant: 'kopi abc',
        counterparty: null,
        since: now.subtract(const Duration(hours: 48)),
      ),
      isTrue,
    );
    expect(
      await repo.hasRecentSimilar(
        sourcePackage: 'com.bank.app',
        amount: 99999,
        type: DetectionTransactionType.expense,
        merchant: 'kopi abc',
        counterparty: null,
        since: now.subtract(const Duration(hours: 48)),
      ),
      isFalse,
    );
  });

  test('resolves candidates and learns merchant rules', () async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(id: const Value('cat-food'), name: 'Food & Dining', type: CategoryType.expense),
        );
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(id: const Value('acc-1'), name: 'BCA', type: AccountType.assets),
        );
    await repo.saveCandidate(model('d1'));
    await repo.learnMerchantCategory(merchant: 'KOPI ABC', categoryId: 'cat-food');

    expect(await repo.getLearnedCategory('kopi abc'), 'cat-food');

    await repo.resolveCandidate(id: 'd1', status: DetectionStatus.imported, accountId: 'acc-1', categoryId: 'cat-food');
    expect(await repo.countPending(), 0);
    final learned = await db.select(db.merchantCategoryRules).get();
    expect(learned.first.hitCount, 1);

    // Learning the same merchant again reinforces the rule.
    await repo.learnMerchantCategory(merchant: 'KOPI ABC', categoryId: 'cat-food');
    final reinforced = await db.select(db.merchantCategoryRules).get();
    expect(reinforced.first.hitCount, 2);
  });

  test('records salary observations', () async {
    expect(await repo.hasSalaryRecord(), isFalse);
    await repo.recordSalary(amount: 10000000, dayOfMonth: 25, confidence: 0.9);
    expect(await repo.hasSalaryRecord(), isTrue);
    await repo.recordSalary(amount: 10000000, dayOfMonth: 25, confidence: 0.7);
    final profiles = await db.select(db.salaryProfiles).get();
    expect(profiles.first.occurrenceCount, 2);
  });

  test('persists detection settings', () async {
    expect(await repo.getSetting('detectionEnabled') == null, isTrue);
    await repo.setSetting('detectionEnabled', 'false');
    expect(await repo.getSetting('detectionEnabled'), 'false');
  });
}
