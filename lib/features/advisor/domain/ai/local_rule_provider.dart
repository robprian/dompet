/// Local rule-based advisor provider (existing deterministic engine).
library;

import 'package:dompet/features/advisor/domain/advisor_engine.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:dompet/features/advisor/domain/allocation_engine.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Local rule-based advisor provider (wraps the existing deterministic engine).
class LocalRuleProvider implements AdvisorProvider {
  LocalRuleProvider({
    AdvisorEngine? engine,
  }) : _engine = engine ?? AdvisorEngine();

  final AdvisorEngine _engine;

  @override
  String get id => 'local-rules';

  @override
  String get name => 'Local Rules (Offline)';

  @override
  bool get requiresApiKey => false;

  @override
  Future<AdvisorResponse> analyze(AdvisorContext context) async {
    final snapshot = AdvisorSnapshot(
      income: context.incomeSummary.total,
      expense: context.expenseSummary.total,
      accounts: [], // Not needed for local engine
      transactions: context.recentTransactions
          .map(
            (t) => TransactionModel(
              id: t.id,
              accountId: '',
              type: t.type,
              amount: t.amount,
              transactionDate: t.date,
              createdAt: t.date,
              updatedAt: t.date,
              items: [
                TransactionItemModel(
                  id: const Uuid().v7(),
                  transactionId: t.id,
                  amount: t.amount,
                  categoryId: t.category,
                  createdAt: t.date,
                  updatedAt: t.date,
                ),
              ],
            ),
          )
          .toList(),
      budgets: [],
      budgetSpent: {},
      goalsTarget: context.goals.fold(0, (sum, g) => sum + g.targetAmount),
      goalsSaved: context.goals.fold(0, (sum, g) => sum + g.currentAmount),
      debtRemaining: context.debts.fold(0, (sum, d) => sum + d.remainingAmount),
    );

    final localRecommendations = _engine.analyze(snapshot);

    return AdvisorResponse(
      recommendations: localRecommendations
          .map(
            (r) => AdvisorRecommendation(
              type: r.type.name,
              severity: _mapSeverity(r.severity),
              title: _typeToTitle(r.type),
              message: _typeToMessage(r),
              amount: r.amount,
              ratio: r.ratio,
              relatedName: r.relatedName,
            ),
          )
          .toList(),
    );
  }

  static AISeverity _mapSeverity(AdvisorSeverity severity) {
    return switch (severity) {
      AdvisorSeverity.warning => AISeverity.warning,
      AdvisorSeverity.success => AISeverity.info,
      AdvisorSeverity.info => AISeverity.info,
    };
  }

  String _typeToTitle(AdvisorRecommendationType type) {
    return switch (type) {
      AdvisorRecommendationType.salaryAllocation => 'Salary Allocation',
      AdvisorRecommendationType.budget => 'Budget Alert',
      AdvisorRecommendationType.overspending => 'Overspending Alert',
      AdvisorRecommendationType.largeTransaction => 'Large Transaction',
      AdvisorRecommendationType.savingsRate => 'Savings Rate',
      AdvisorRecommendationType.cashFlow => 'Cash Flow Alert',
      AdvisorRecommendationType.recurringExpense => 'Recurring Expense',
    };
  }

  String _typeToMessage(AdvisorRecommendationModel r) {
    return switch (r.type) {
      AdvisorRecommendationType.salaryAllocation => _salaryAllocationMessage(r.amount ?? 0),
      AdvisorRecommendationType.budget => _budgetMessage(r),
      AdvisorRecommendationType.overspending => 'Unusual spending detected: ${r.amount}',
      AdvisorRecommendationType.largeTransaction => 'Large transaction detected: ${r.amount}',
      AdvisorRecommendationType.savingsRate => _savingsMessage(r),
      AdvisorRecommendationType.cashFlow => 'Negative cash flow: ${r.amount}',
      AdvisorRecommendationType.recurringExpense => 'Recurring expense detected: ${r.amount}',
    };
  }

  String _salaryAllocationMessage(int amount) {
    final plan = AllocationEngine().allocate(amount);
    return 'Suggested allocation: Needs ${plan.needs}, Savings ${plan.savings}, '
        'Debt ${plan.debt}, Lifestyle ${plan.lifestyle}, Buffer ${plan.buffer}';
  }

  String _budgetMessage(AdvisorRecommendationModel r) {
    if (r.ratio != null && r.ratio! >= 1) {
      return 'Budget "${r.relatedName}" exceeded by ${r.amount}';
    }
    final ratio = (r.ratio ?? 0) * 100;
    return 'Budget "${r.relatedName}" at ${ratio.toStringAsFixed(0)}%';
  }

  String _savingsMessage(AdvisorRecommendationModel r) {
    final ratio = r.ratio ?? 0;
    return 'Savings rate is ${(ratio * 100).toStringAsFixed(1)}%';
  }

  @override
  Future<String> explainTransaction(TransactionContext context) async {
    return 'This ${context.transaction.type.name} of ${context.transaction.amount} '
        'was made at ${context.transaction.merchant ?? "unknown merchant"} '
        'in the ${context.categoryName} category.';
  }

  @override
  Future<String> summarizeMonth(MonthlySummaryContext context) async {
    return 'This month you earned ${context.income} and spent ${context.expenses}. '
        'Your savings rate is ${((context.income - context.expenses) / context.income * 100).toStringAsFixed(1)}%. '
        '${context.largeTransactions.isNotEmpty ? "Large transactions: ${context.largeTransactions.join(", ")}" : ""}';
  }

  @override
  Future<BudgetPlanResponse> generateBudgetPlan(BudgetContext context) async {
    return const BudgetPlanResponse(allocations: {});
  }

  @override
  Future<CashFlowAnalysisResponse> analyzeCashFlow(CashFlowContext context) async {
    return const CashFlowAnalysisResponse(
      summary: 'Cash flow analysis not available locally',
    );
  }

  @override
  Future<bool> isAvailable() async => true;
}
