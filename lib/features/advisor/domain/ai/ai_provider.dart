/// AI provider abstraction for Dompet.
library;

import 'package:dompet/core/enums.dart' show DebtType, TransactionType;

/// Interface for AI providers that can generate financial advice.
abstract class AdvisorProvider {
  /// The unique identifier of this provider.
  String get id;

  /// Human-readable name of the provider.
  String get name;

  /// Whether this provider requires an API key.
  bool get requiresApiKey;

  /// Generate a financial analysis and recommendations.
  Future<AdvisorResponse> analyze(AdvisorContext context);

  /// Generate a natural language explanation for a transaction.
  Future<String> explainTransaction(TransactionContext context);

  /// Generate a monthly summary.
  Future<String> summarizeMonth(MonthlySummaryContext context);

  /// Generate a budget plan.
  Future<BudgetPlanResponse> generateBudgetPlan(BudgetContext context);

  /// Analyze cash flow patterns.
  Future<CashFlowAnalysisResponse> analyzeCashFlow(CashFlowContext context);

  /// Check if the provider is available/configured.
  Future<bool> isAvailable();
}

/// Result of an advisor analysis.
class AdvisorResponse {
  const AdvisorResponse({
    required this.recommendations,
    this.explanation,
  });

  final List<AdvisorRecommendation> recommendations;
  final String? explanation;
}

/// A single financial recommendation.
class AdvisorRecommendation {
  const AdvisorRecommendation({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.amount,
    this.ratio,
    this.relatedName,
  });

  final String type;
  final AISeverity severity;
  final String title;
  final String message;
  final int? amount;
  final double? ratio;
  final String? relatedName;
}

/// Severity levels for recommendations.
enum AISeverity { info, warning, critical }

/// Context for advisor analysis.
class AdvisorContext {
  const AdvisorContext({
    required this.incomeSummary,
    required this.expenseSummary,
    required this.budgetSummary,
    required this.categorySummary,
    required this.cashFlow,
    required this.goals,
    required this.debts,
    required this.recentTransactions,
    required this.recurringExpenses,
  });

  final IncomeSummary incomeSummary;
  final ExpenseSummary expenseSummary;
  final BudgetSummary budgetSummary;
  final CategorySummary categorySummary;
  final CashFlowSummary cashFlow;
  final List<GoalSummary> goals;
  final List<DebtSummary> debts;
  final List<TransactionSummary> recentTransactions;
  final List<RecurringExpenseSummary> recurringExpenses;
}

class IncomeSummary {
  const IncomeSummary({required this.total, required this.byCategory});
  final int total;
  final Map<String, int> byCategory;
}

class ExpenseSummary {
  const ExpenseSummary({required this.total, required this.byCategory});
  final int total;
  final Map<String, int> byCategory;
}

class BudgetSummary {
  const BudgetSummary({required this.budgets});
  final List<BudgetStatus> budgets;
}

class BudgetStatus {
  const BudgetStatus({
    required this.id,
    required this.name,
    required this.amount,
    required this.spent,
    required this.category,
  });

  final String id;
  final String name;
  final int amount;
  final int spent;
  final String category;
}

class CategorySummary {
  const CategorySummary({required this.byCategory});
  final Map<String, int> byCategory;
}

class CashFlowSummary {
  const CashFlowSummary({
    required this.netCashFlow,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.trend,
  });

  final int netCashFlow;
  final double weeklyAverage;
  final double monthlyAverage;
  final CashFlowTrend trend;
}

enum CashFlowTrend { improving, stable, declining }

class GoalSummary {
  const GoalSummary({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime targetDate;
}

class DebtSummary {
  const DebtSummary({
    required this.id,
    required this.personName,
    required this.type,
    required this.amount,
    required this.remainingAmount,
    required this.dueDate,
  });

  final String id;
  final String personName;
  final DebtType type;
  final int amount;
  final int remainingAmount;
  final DateTime? dueDate;
}

class TransactionSummary {
  const TransactionSummary({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.merchant,
    required this.date,
  });

  final String id;
  final int amount;
  final TransactionType type;
  final String? category;
  final String? merchant;
  final DateTime date;
}

class RecurringExpenseSummary {
  const RecurringExpenseSummary({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextDate,
  });

  final String id;
  final String name;
  final int amount;
  final RecurringFrequency frequency;
  final DateTime nextDate;
}

enum RecurringFrequency { daily, weekly, monthly, yearly }

/// Context for transaction explanation.
class TransactionContext {
  const TransactionContext({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
  });

  final TransactionSummary transaction;
  final String accountName;
  final String categoryName;
}

/// Context for monthly summary.
class MonthlySummaryContext {
  const MonthlySummaryContext({
    required this.month,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.budgetPerformance,
    required this.topCategories,
    required this.largeTransactions,
  });

  final DateTime month;
  final int income;
  final int expenses;
  final int savings;
  final Map<String, double> budgetPerformance;
  final List<String> topCategories;
  final List<String> largeTransactions;
}

/// Context for budget planning.
class BudgetContext {
  const BudgetContext({
    required this.income,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.goals,
    required this.debts,
  });

  final int income;
  final Map<String, int> fixedExpenses;
  final Map<String, int> variableExpenses;
  final List<GoalSummary> goals;
  final List<DebtSummary> debts;
}

/// Response for budget plan generation.
class BudgetPlanResponse {
  const BudgetPlanResponse({
    required this.allocations,
    this.notes,
  });

  final Map<String, int> allocations;
  final String? notes;
}

/// Context for cash flow analysis.
class CashFlowContext {
  const CashFlowContext({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.cashFlowHistory,
    required this.recurringIncome,
    required this.recurringExpenses,
    required this.upcomingPayments,
  });

  final int monthlyIncome;
  final int monthlyExpenses;
  final List<CashFlowPoint> cashFlowHistory;
  final List<RecurringItem> recurringIncome;
  final List<RecurringItem> recurringExpenses;
  final List<UpcomingPayment> upcomingPayments;
}

class CashFlowPoint {
  const CashFlowPoint({required this.date, required this.netFlow});
  final DateTime date;
  final int netFlow;
}

/// Response for cash flow analysis.
class CashFlowAnalysisResponse {
  const CashFlowAnalysisResponse({required this.summary, this.trend = CashFlowTrend.stable});

  /// Natural language summary of the cash flow analysis.
  final String summary;

  /// Overall cash flow trend.
  final CashFlowTrend trend;
}

class RecurringItem {
  const RecurringItem({
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextDate,
  });

  final String name;
  final int amount;
  final RecurringFrequency frequency;
  final DateTime nextDate;
}

class UpcomingPayment {
  const UpcomingPayment({
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.type,
  });

  final String name;
  final int amount;
  final DateTime dueDate;
  final PaymentType type;
}

enum PaymentType { recurring, oneTime, debt }
