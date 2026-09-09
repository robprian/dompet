import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(connection: NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schema v2 contains the detection tables', () async {
    expect(db.schemaVersion, 2);
    expect(await db.select(db.transactionDetections).get(), isEmpty);
    expect(await db.select(db.merchantCategoryRules).get(), isEmpty);
    expect(await db.select(db.salaryProfiles).get(), isEmpty);
  });

  test('detection DAO enforces fingerprint uniqueness', () async {
    await db.detectionDao.insertDetection(
      TransactionDetectionsCompanion.insert(
        sourcePackage: 'com.bank.app',
        type: DetectionTransactionType.expense,
        amount: 25000,
        confidence: 0.9,
        confidenceTier: ConfidenceTier.high,
        method: PaymentMethod.qris,
        parserVersion: 'qris-v1',
        fingerprint: 'unique-fp',
        occurredAt: DateTime.now().toUtc(),
      ),
    );
    expect(await db.detectionDao.hasFingerprint('unique-fp'), isTrue);
    await expectLater(
      db.detectionDao.insertDetection(
        TransactionDetectionsCompanion.insert(
          sourcePackage: 'com.bank.app',
          type: DetectionTransactionType.expense,
          amount: 25000,
          confidence: 0.9,
          confidenceTier: ConfidenceTier.high,
          method: PaymentMethod.qris,
          parserVersion: 'qris-v1',
          fingerprint: 'unique-fp',
          occurredAt: DateTime.now().toUtc(),
        ),
      ),
      throwsA(anything),
    );
  });

  test('pending stream only emits reviewable candidates', () async {
    Future<void> insert(String fingerprint, DetectionStatus status) {
      return db.detectionDao.insertDetection(
        TransactionDetectionsCompanion.insert(
          sourcePackage: 'com.bank.app',
          type: DetectionTransactionType.expense,
          amount: 10000,
          confidence: 0.7,
          confidenceTier: ConfidenceTier.likely,
          method: PaymentMethod.bank,
          parserVersion: 'bank-transfer-v1',
          status: Value(status),
          fingerprint: fingerprint,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
    }

    await insert('fp-pending', DetectionStatus.pending);
    await insert('fp-imported', DetectionStatus.imported);
    await insert('fp-ignored', DetectionStatus.ignored);

    final pending = await db.detectionDao.watchPending().first;
    expect(pending.map((row) => row.id).toList(), hasLength(1));
  });
}
