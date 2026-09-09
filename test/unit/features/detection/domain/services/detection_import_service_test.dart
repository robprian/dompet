import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/accounts/data/account_repository_impl.dart';
import 'package:dompet/features/categories/data/category_repository_impl.dart';
import 'package:dompet/features/detection/data/detection_repository.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:dompet/features/transactions/data/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late DetectionImportService service;

  setUp(() async {
    db = AppDatabase(connection: NativeDatabase.memory());
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('acc-main'),
            name: 'BCA',
            type: AccountType.assets,
            balance: const Value(0),
          ),
        );
    service = DetectionImportService(
      DetectionRepository(db.detectionDao, db),
      TransactionRepositoryImpl(db.transactionsDao),
      AccountRepositoryImpl(db.accountsDao),
      CategoryRepositoryImpl(db.categoriesDao),
    );
  });

  tearDown(() async {
    await db.close();
  });

  NotificationPayload payload(String body) {
    return NotificationPayload(
      package: 'com.bank.app',
      title: '',
      body: body,
      postedAt: DateTime.utc(2026, 3, 15, 10, 30),
    );
  }

  Future<int> totalBalance() async {
    final rows = await db.select(db.accounts).get();
    var sum = 0;
    for (final row in rows) {
      sum += row.balance;
    }
    return sum;
  }

  test('QRIS expense auto-imports and deducts the balance', () async {
    final outcome = await service.handle(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));

    expect(outcome.type, ImportOutcomeType.imported);
    expect(outcome.amount, 25000);
    expect(await totalBalance(), -25000);

    final transactions = await (db.select(db.transactions)).get();
    expect(transactions, hasLength(1));
    expect(transactions.first.type, TransactionType.expense);
  });

  test('duplicate notifications are rejected without double import', () async {
    final first = await service.handle(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));
    expect(first.type, ImportOutcomeType.imported);

    final second = await service.handle(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));
    expect(second.type, ImportOutcomeType.duplicate);
    expect(await totalBalance(), -25000);
  });

  test('low-confidence and unknown notifications are discarded', () async {
    final outcome = await service.handle(payload('Cuaca hari ini cerah sekali ya'));
    expect(outcome.type, ImportOutcomeType.discarded);

    final rows = await db.select(db.transactionDetections).get();
    expect(rows, isEmpty);
  });

  test('failed payments are never imported', () async {
    final outcome = await service.handle(payload('Pembayaran QRIS Rp25.000 di KOPI ABC gagal'));
    expect(outcome.type, ImportOutcomeType.discarded);
    expect(await totalBalance(), 0);
  });

  test('likely income is stored for review', () async {
    final outcome = await service.handle(payload('Dana masuk Rp200.000 diterima'));
    expect(outcome.type, ImportOutcomeType.review);
    expect(outcome.detectionId != null, isTrue);

    final rows = await db.select(db.transactionDetections).get();
    expect(rows, hasLength(1));
    expect(rows.first.status, DetectionStatus.pending);
    // Review queue must not mutate balances.
    expect(await totalBalance(), 0);
  });

  test('salary income records a salary profile on import', () async {
    final anchor = DateTime.now().toUtc().subtract(const Duration(days: 62));
    final priorSalaryDate = DateTime.utc(anchor.year, anchor.month, 15);
    await db.transactionsDao.insertTransactionWithItems(
      TransactionsCompanion.insert(
        id: const Value('txn-salary-1'),
        accountId: 'acc-main',
        type: TransactionType.income,
        amount: 10000000,
        transactionDate: priorSalaryDate,
      ),
      [const TransactionItemsCompanion(id: Value('item-salary-1'), amount: Value(10000000))],
    );

    // The monthly salary text must parse at high parser confidence.
    final outcome = await service.handle(
      payload('Transfer masuk Rp10.000.000 gaji bulanan dari PT MAJU berhasil'),
    );
    final profiles = await db.select(db.salaryProfiles).get();
    if (outcome.type == ImportOutcomeType.imported) {
      expect(profiles, hasLength(1));
      expect(profiles.first.amount, 10000000);
    } else {
      expect(outcome.type, ImportOutcomeType.review);
      expect(outcome.isSalary, isTrue);
    }
  });

  test('disabled detection discards everything', () async {
    await db.into(db.settings).insertOnConflictUpdate(
          const SettingsCompanion(key: Value('detectionEnabled'), value: Value('false')),
        );

    final outcome = await service.handle(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));
    expect(outcome.type, ImportOutcomeType.discarded);
  });
}
