import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/advisor_engine.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_list_notifier.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_progress_provider.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/features/debts/presentation/controllers/debt_list_notifier.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'advisor_notifier.g.dart';

/// State for the Dompet Advisor screen.
class AdvisorState {
  /// Creates an advisor state.
  const AdvisorState({this.recommendations = const [], this.isLoading = true});

  /// Computed recommendations.
  final List<AdvisorRecommendationModel> recommendations;

  /// Whether the analysis is still running.
  final bool isLoading;
}

/// Computes offline financial recommendations reactively.
@riverpod
class AdvisorNotifier extends _$AdvisorNotifier {
  @override
  AdvisorState build() {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(recentTransactionsStreamProvider);
    final budgetsAsync = ref.watch(budgetListProvider);
    final goalsAsync = ref.watch(goalProvider);
    final debtsAsync = ref.watch(debtListProvider);

    final accounts = accountsAsync.value ?? <AccountModel>[];
    final transactions = transactionsAsync.value ?? <TransactionModel>[];
    final budgets = budgetsAsync.value ?? <BudgetModel>[];
    final goals = goalsAsync.value ?? <GoalModel>[];
    final debts = debtsAsync.value ?? <DebtModel>[];

    final isLoading = accountsAsync.isLoading || transactionsAsync.isLoading || budgetsAsync.isLoading;

    final recommendations = _analyze(accounts, transactions, budgets, goals, debts);
    return AdvisorState(recommendations: recommendations, isLoading: isLoading);
  }

  List<AdvisorRecommendationModel> _analyze(
    List<AccountModel> accounts,
    List<TransactionModel> transactions,
    List<BudgetModel> budgets,
    List<GoalModel> goals,
    List<DebtModel> debts,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    var income = 0;
    var expense = 0;
    for (final tx in transactions) {
      if (tx.transactionDate.toUtc().isBefore(monthStart.toUtc())) continue;
      if (tx.type == TransactionType.income) income += tx.amount;
      if (tx.type == TransactionType.expense) expense += tx.amount;
    }

    final goalsTarget = goals.fold<int>(0, (sum, g) => sum + g.targetAmount);
    final accountsById = {for (final a in accounts) a.id: a};
    final goalsSaved = goals.fold<int>(0, (sum, g) => sum + (accountsById[g.accountId]?.balance ?? 0));
    final debtRemaining = debts.fold<int>(0, (sum, d) => sum + d.remainingAmount);

    final engine = ref.read(advisorEngineProvider);
    return engine.analyze(
      AdvisorSnapshot(
        income: income,
        expense: expense,
        accounts: accounts,
        transactions: transactions,
        budgets: budgets,
        budgetSpent: _budgetSpent(budgets),
        goalsTarget: goalsTarget,
        goalsSaved: goalsSaved,
        debtRemaining: debtRemaining,
      ),
    );
  }

  Map<String, int> _budgetSpent(List<BudgetModel> budgets) {
    final spent = <String, int>{};
    for (final budget in budgets) {
      spent[budget.id] = ref.watch(budgetProgressProvider(budget)).value ?? 0;
    }
    return spent;
  }
}

/// Engine provider for the advisor notifier.
final advisorEngineProvider = Provider<AdvisorEngine>((ref) => AdvisorEngine());
