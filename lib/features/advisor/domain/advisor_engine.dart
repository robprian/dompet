import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/advisor/domain/allocation_engine.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Snapshot consumed by the offline Dompet Advisor engine.
class AdvisorSnapshot {
  /// Creates an advisor input snapshot.
  const AdvisorSnapshot({
    required this.income,
    required this.expense,
    required this.accounts,
    required this.transactions,
    required this.budgets,
    required this.budgetSpent,
    required this.goalsTarget,
    required this.goalsSaved,
    required this.debtRemaining,
  });

  /// Period income.
  final int income;

  /// Period expense.
  final int expense;

  /// Current accounts.
  final List<AccountModel> accounts;

  /// Period transactions.
  final List<TransactionModel> transactions;

  /// Active budgets.
  final List<BudgetModel> budgets;

  /// Actual spend keyed by budget id.
  final Map<String, int> budgetSpent;

  /// Sum of active goal targets.
  final int goalsTarget;

  /// Sum saved toward active goals.
  final int goalsSaved;

  /// Outstanding debt/loan balance.
  final int debtRemaining;
}

/// Deterministic rules for useful personal-finance recommendations.
class AdvisorEngine {
  /// Creates an advisor engine with an optional allocation strategy.
  AdvisorEngine({AllocationEngine? allocationEngine}) : _allocationEngine = allocationEngine ?? AllocationEngine();

  final AllocationEngine _allocationEngine;
  static const Uuid _uuid = Uuid();

  /// Analyzes a snapshot without network access or external services.
  List<AdvisorRecommendationModel> analyze(AdvisorSnapshot snapshot) {
    final recommendations = <AdvisorRecommendationModel>[];
    if (snapshot.income > 0) {
      recommendations.add(
        AdvisorRecommendationModel(
          id: _uuid.v7(),
          type: AdvisorRecommendationType.salaryAllocation,
          severity: AdvisorSeverity.info,
          amount: _allocationEngine.allocate(snapshot.income).income,
          isSalaryRelated: true,
        ),
      );
    }

    for (final budget in snapshot.budgets) {
      if (budget.amount <= 0) continue;
      final spent = snapshot.budgetSpent[budget.id] ?? 0;
      final ratio = spent / budget.amount;
      if (ratio >= 1) {
        recommendations.add(
          AdvisorRecommendationModel(
            id: _uuid.v7(),
            type: AdvisorRecommendationType.budget,
            severity: AdvisorSeverity.warning,
            amount: spent,
            ratio: ratio,
            relatedName: budget.name,
          ),
        );
      } else if (ratio >= 0.8) {
        recommendations.add(
          AdvisorRecommendationModel(
            id: _uuid.v7(),
            type: AdvisorRecommendationType.budget,
            severity: AdvisorSeverity.warning,
            amount: budget.amount - spent,
            ratio: ratio,
            relatedName: budget.name,
          ),
        );
      }
    }

    if (snapshot.income > 0) {
      final savingsRate = (snapshot.income - snapshot.expense) / snapshot.income;
      if (savingsRate < 0) {
        recommendations.add(
          AdvisorRecommendationModel(
            id: _uuid.v7(),
            type: AdvisorRecommendationType.cashFlow,
            severity: AdvisorSeverity.warning,
            amount: snapshot.expense - snapshot.income,
            ratio: savingsRate,
          ),
        );
      } else if (savingsRate < 0.1) {
        recommendations.add(
          AdvisorRecommendationModel(
            id: _uuid.v7(),
            type: AdvisorRecommendationType.savingsRate,
            severity: AdvisorSeverity.warning,
            ratio: savingsRate,
          ),
        );
      }
    }

    final expenses = snapshot.transactions.where((t) => t.type == TransactionType.expense).map((t) => t.amount).toList();
    if (expenses.length >= 3) {
      var sum = 0;
      for (final amount in expenses) {
        sum += amount;
      }
      final average = sum / expenses.length;
      var large = 0;
      for (final amount in expenses) {
        if (amount >= average * 3 && amount > large) large = amount;
      }
      if (large > 0) {
        recommendations.add(
          AdvisorRecommendationModel(
            id: _uuid.v7(),
            type: AdvisorRecommendationType.largeTransaction,
            severity: AdvisorSeverity.info,
            amount: large,
          ),
        );
      }
    }

    if (snapshot.goalsTarget > 0 && snapshot.goalsSaved < snapshot.goalsTarget) {
      recommendations.add(
        AdvisorRecommendationModel(
          id: _uuid.v7(),
          type: AdvisorRecommendationType.savingsRate,
          severity: AdvisorSeverity.info,
          amount: snapshot.goalsTarget - snapshot.goalsSaved,
        ),
      );
    }
    return recommendations;
  }
}
