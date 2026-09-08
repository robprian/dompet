import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/core/utils/datetime_utils.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/transactions/data/transaction_repository_impl.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late TransactionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(connection: NativeDatabase.memory());
    repository = TransactionRepositoryImpl(db.transactionsDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('restoreTransaction', () {
    test('restores deleted transaction and re-applies account balance mutation', () async {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: const Value('acc1'),
              name: 'Wallet',
              type: AccountType.assets,
              balance: const Value(100000),
            ),
          );

      final tx = TransactionModel(
        id: 'txn-delete-restore',
        accountId: 'acc1',
        type: TransactionType.expense,
        amount: 30000,
        transactionDate: DateTimeUtils.nowUtc(),
        createdAt: DateTimeUtils.nowUtc(),
        updatedAt: DateTimeUtils.nowUtc(),
        items: [
          TransactionItemModel(
            id: 'item-1',
            transactionId: 'txn-delete-restore',
            amount: 30000,
            createdAt: DateTimeUtils.nowUtc(),
            updatedAt: DateTimeUtils.nowUtc(),
          ),
        ],
      );

      // 1. Create transaction -> balance becomes 70000
      await repository.createTransaction(tx);
      var account = await (db.select(db.accounts)..where((a) => a.id.equals('acc1'))).getSingle();
      expect(account.balance, 70000);

      // 2. Delete transaction -> balance reverts to 100000
      await repository.deleteTransaction(tx.id);
      account = await (db.select(db.accounts)..where((a) => a.id.equals('acc1'))).getSingle();
      expect(account.balance, 100000);

      var txInDb = await repository.getTransactionById(tx.id);
      expect(txInDb, isA<ErrorResult<TransactionModel, Failure>>());

      // 3. Restore transaction -> balance returns to 70000 and tx exists
      final restoreResult = await repository.restoreTransaction(tx);
      expect(restoreResult, isA<Success<void, Failure>>());

      account = await (db.select(db.accounts)..where((a) => a.id.equals('acc1'))).getSingle();
      expect(account.balance, 70000);

      txInDb = await repository.getTransactionById(tx.id);
      expect(txInDb, isA<Success<TransactionModel, Failure>>());
      final restoredModel = (txInDb as Success<TransactionModel, Failure>).value;
      expect(restoredModel.id, tx.id);
      expect(restoredModel.items.length, 1);
      expect(restoredModel.items.first.amount, 30000);
    });
  });
}
