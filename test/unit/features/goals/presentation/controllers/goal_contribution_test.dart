import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_detail_notifier.dart';

/// Verifies that goal contributions are pure allocations: the source account
/// decreases, the goal pocket increases, and no expense is ever recorded.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime.now().toUtc();

  setUp(() async {
    db = AppDatabase(connection: NativeDatabase.memory());
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('wallet'),
            name: 'Wallet',
            type: AccountType.assets,
            balance: const Value(1000000),
          ),
        );
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('goal-pocket'),
            name: 'Goal: NMAX',
            type: AccountType.goal,
            balance: const Value(0),
          ),
        );
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  GoalModel goal() => GoalModel(
    id: 'g1',
    accountId: 'goal-pocket',
    name: 'Beli NMAX',
    targetAmount: 5000000,
    createdAt: now,
    updatedAt: now,
  );

  Future<Account> account(String id) => (db.select(db.accounts)..where((a) => a.id.equals(id))).getSingle();

  test('contribute reallocates balance without creating an expense', () async {
    final source = await account('wallet');
    final result = await container
        .read(goalDetailProvider.notifier)
        .contribute(goal: goal(), source: _toModel(source), amount: 250000);

    expect(result, isA<Success<void, Object>>());
    expect((await account('wallet')).balance, 750000);
    expect((await account('goal-pocket')).balance, 250000);

    final txs = await db.select(db.transactions).get();
    expect(txs, hasLength(1));
    expect(txs.single.type, TransactionType.transfer);
    expect(txs.single.destinationAccountId, 'goal-pocket');
    expect(txs.where((t) => t.type == TransactionType.expense), isEmpty);
  });

  test('contribute rejects amounts above the source balance', () async {
    final source = await account('wallet');
    final result = await container
        .read(goalDetailProvider.notifier)
        .contribute(goal: goal(), source: _toModel(source), amount: 2000000);

    expect(result, isA<ErrorResult<void, Object>>());
    expect((await account('wallet')).balance, 1000000);
    expect((await account('goal-pocket')).balance, 0);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('contribute rejects the goal pocket as its own source', () async {
    final source = await account('goal-pocket');
    final result = await container
        .read(goalDetailProvider.notifier)
        .contribute(goal: goal(), source: _toModel(source), amount: 1000);

    expect(result, isA<ErrorResult<void, Object>>());
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('withdraw moves funds back out of the goal pocket', () async {
    final source = await account('wallet');
    await container
        .read(goalDetailProvider.notifier)
        .contribute(goal: goal(), source: _toModel(source), amount: 300000);
    final destination = await account('wallet');

    final result = await container
        .read(goalDetailProvider.notifier)
        .withdraw(goal: goal(), destination: _toModel(destination), amount: 100000);

    expect(result, isA<Success<void, Object>>());
    expect((await account('wallet')).balance, 800000);
    expect((await account('goal-pocket')).balance, 200000);
  });
}

AccountModel _toModel(Account account) => AccountModel(
  id: account.id,
  name: account.name,
  type: account.type,
  balance: account.balance,
  isActive: account.isActive,
  createdAt: account.createdAt,
  updatedAt: account.updatedAt,
);
