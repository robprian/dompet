import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/presentation/controllers/advisor_notifier.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/budgets/domain/i_budget_repository.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_list_notifier.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_progress_provider.dart';
import 'package:dompet/features/debts/presentation/controllers/debt_list_notifier.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/dashboard/presentation/controllers/dashboard_notifier.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/features/debts/presentation/controllers/debt_list_notifier.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';

import 'dart:async';

import 'package:dompet/features/advisor/presentation/controllers/advisor_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final _now = DateTime.now().toUtc();

AccountModel account({String id = 'a1', int balance = 10000000}) {
  return AccountModel(
    id: id,
    name: 'BCA',
    type: AccountType.assets,
    balance: balance,
    createdAt: _now,
    updatedAt: _now,
  );
}

TransactionModel incomeTx(int amount) {
  return TransactionModel(
    id: 'income-$amount',
    accountId: 'a1',
    type: TransactionType.income,
    amount: amount,
    transactionDate: DateTime(_now.year, _now.month, 5).toUtc(),
    createdAt: _now,
    updatedAt: _now,
  );
}

TransactionModel expenseTx(int amount, String id) {
  return TransactionModel(
    id: id,
    accountId: 'a1',
    type: TransactionType.expense,
    amount: amount,
    transactionDate: DateTime(_now.year, _now.month, 6).toUtc(),
    createdAt: _now,
    updatedAt: _now,
  );
}

class FakeBudgetList extends BudgetListNotifier {
  FakeBudgetList(this.items);

  final List<BudgetModel> items;

  @override
  Future<List<BudgetModel>> build() async => items;
}

class FakeGoals extends GoalNotifier {
  @override
  Stream<List<GoalModel>> build() => Stream.value([]);
}

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockTransactionRepository extends Mock implements ITransactionRepository {}

class FakeDebts extends DebtList {
  @override
  Stream<List<DebtModel>> build() => Stream.value([]);
}

Future<AdvisorState> settled(ProviderContainer container) async {
  final current = container.read(advisorProvider);
  if (!current.isLoading) return current;
  final completer = Completer<AdvisorState>();
  late final ProviderSubscription<AdvisorState> subscription;
  subscription = container.listen(advisorProvider, (previous, next) {
    if (!next.isLoading && !completer.isCompleted) {
      completer.complete(next);
      subscription.close();
    }
  }, fireImmediately: true);
  return completer.future.timeout(const Duration(seconds: 5));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  ProviderContainer container({
    List<AccountModel>? accounts,
    List<TransactionModel>? transactions,
    List<BudgetModel>? budgets,
  }) {
    return ProviderContainer(
      overrides: [
        accountsStreamProvider.overrideWith((ref) => Stream.value(accounts ?? [account()])),
        recentTransactionsStreamProvider.overrideWith((ref) => Stream.value(transactions ?? [])),
        budgetListProvider.overrideWith(() => FakeBudgetList(budgets ?? [])),
        goalProvider.overrideWith(FakeGoals.new),
        debtListProvider.overrideWith(FakeDebts.new),
      ],
    );
  }

  test('emits allocation advice for monthly income', () async {
    final c = container(transactions: [incomeTx(10000000), expenseTx(4000000, 'e1')]);
    addTearDown(c.dispose);
    final state = await settled(c);
    expect(state.isLoading, isFalse);
    expect(
      state.recommendations.any((r) => r.type == AdvisorRecommendationType.salaryAllocation),
      isTrue,
    );
    expect(state.recommendations.any((r) => r.severity == AdvisorSeverity.warning), isFalse);
  });

  test('flags breached budgets', () async {
    final budget = BudgetModel(
      id: 'b1',
      name: 'Makan',
      amount: 1000000,
      period: BudgetPeriod.monthly,
      startDate: DateTime(_now.year, _now.month),
      createdAt: _now,
      updatedAt: _now,
    );
    final budgetRepo = MockBudgetRepository();
    final transactionRepo = MockTransactionRepository();
    when(
      () => transactionRepo.watchTransactions(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        accountIds: any(named: 'accountIds'),
        categoryIds: any(named: 'categoryIds'),
        types: any(named: 'types'),
        debtIds: any(named: 'debtIds'),
        recurringIds: any(named: 'recurringIds'),
      ),
    ).thenAnswer((_) => Stream.value(const Success([])));
    when(
      () => budgetRepo.getSpentAmountForBudget(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
      ),
    ).thenAnswer((_) async => const Success(1200000));
    final scoped = ProviderContainer(
      overrides: [
        accountsStreamProvider.overrideWith((ref) => Stream.value([account()])),
        recentTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value([incomeTx(10000000), expenseTx(1500000, 'e1')]),
        ),
        budgetListProvider.overrideWith(() => FakeBudgetList([budget])),
        budgetRepositoryProvider.overrideWithValue(budgetRepo),
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
        goalProvider.overrideWith(FakeGoals.new),
        debtListProvider.overrideWith(FakeDebts.new),
      ],
    );
    addTearDown(scoped.dispose);
    final progressSubscription = scoped.listen(budgetProgressProvider(budget), (previous, next) {});
    addTearDown(progressSubscription.close);
    await scoped.read(budgetProgressProvider(budget).future);
    final state = await settled(scoped);
    final breached = state.recommendations.where(
      (r) => r.type == AdvisorRecommendationType.budget && r.ratio != null && r.ratio! >= 1,
    );
    expect(breached, hasLength(1));
    expect(breached.first.relatedName, 'Makan');
  });

  test('warns on negative cash flow', () async {
    final c = container(transactions: [incomeTx(3000000), expenseTx(5000000, 'e1')]);
    addTearDown(c.dispose);
    final state = await settled(c);
    expect(
      state.recommendations.any((r) => r.type == AdvisorRecommendationType.cashFlow),
      isTrue,
    );
  });
}
