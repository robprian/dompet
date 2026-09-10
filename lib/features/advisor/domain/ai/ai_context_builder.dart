/// Builds structured AI context from application data.
library;

import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:dompet/features/advisor/domain/ai/privacy_filter.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Builds an AdvisorContext from application data.
class AIContextBuilder {
  AIContextBuilder({
    this.privacyFilter,
  });

  final PrivacyFilter? privacyFilter;

  /// Builds a complete AdvisorContext from application data.
  AdvisorContext build({
    required List<TransactionModel> transactions,
    required List<AccountModel> accounts,
    required List<BudgetModel> budgets,
    required List<GoalModel> goals,
    required List<DebtModel> debts,
    required Map<String, int> budgetSpent,
  }) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final context = AdvisorContext(
      incomeSummary: _buildIncomeSummary(transactions, monthStart, monthEnd),
      expenseSummary: _buildExpenseSummary(transactions, monthStart, monthEnd),
      budgetSummary: _buildBudgetSummary(budgets, budgetSpent),
      categorySummary: _buildCategorySummary(transactions, monthStart, monthEnd),
      cashFlow: _buildCashFlow(transactions, monthStart, monthEnd),
      goals: _buildGoals(goals),
      debts: _buildDebts(debts),
      recentTransactions: _buildRecentTransactions(transactions),
      recurringExpenses: _buildRecurringExpenses(transactions),
    );

    if (privacyFilter != null) {
      return privacyFilter!.filter(context);
    }
    return context;
  }

  IncomeSummary _buildIncomeSummary(List<TransactionModel> transactions, DateTime start, DateTime end) {
    final incomeTransactions = transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
              t.transactionDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();

    final byCategory = <String, int>{};
    var total = 0;
    for (final t in incomeTransactions) {
      total += t.amount;
      for (final item in t.items) {
        final cat = item.categoryId ?? 'Uncategorized';
        byCategory[cat] = (byCategory[cat] ?? 0) + item.amount;
      }
    }
    return IncomeSummary(total: total, byCategory: byCategory);
  }

  ExpenseSummary _buildExpenseSummary(List<TransactionModel> transactions, DateTime start, DateTime end) {
    final expenseTransactions = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
              t.transactionDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();

    final byCategory = <String, int>{};
    var total = 0;
    for (final t in expenseTransactions) {
      total += t.amount;
      for (final item in t.items) {
        final cat = item.categoryId ?? 'Uncategorized';
        byCategory[cat] = (byCategory[cat] ?? 0) + item.amount;
      }
    }
    return ExpenseSummary(total: total, byCategory: byCategory);
  }

  BudgetSummary _buildBudgetSummary(List<BudgetModel> budgets, Map<String, int> budgetSpent) {
    final budgetsList = budgets.map((b) {
      final spent = budgetSpent[b.id] ?? 0;
      return BudgetStatus(
        id: b.id,
        name: b.name,
        amount: b.amount,
        spent: spent,
        category: b.categoryId ?? '',
      );
    }).toList();
    return BudgetSummary(budgets: budgetsList);
  }

  CategorySummary _buildCategorySummary(List<TransactionModel> transactions, DateTime start, DateTime end) {
    final expenseTransactions = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
              t.transactionDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();

    final byCategory = <String, int>{};
    for (final t in expenseTransactions) {
      for (final item in t.items) {
        final cat = item.categoryId ?? 'Uncategorized';
        byCategory[cat] = (byCategory[cat] ?? 0) + item.amount;
      }
    }
    return CategorySummary(byCategory: byCategory);
  }

  CashFlowSummary _buildCashFlow(List<TransactionModel> transactions, DateTime start, DateTime end) {
    final monthTransactions = transactions
        .where(
          (t) =>
              t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
              t.transactionDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();

    var income = 0;
    var expense = 0;
    final dailyFlow = <DateTime, int>{};

    for (final t in monthTransactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }

      final day = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      final net = t.type == TransactionType.income ? t.amount : -t.amount;
      dailyFlow[day] = (dailyFlow[day] ?? 0) + net;
    }

    final netCashFlow = income - expense;
    final daysInMonth = end.difference(start).inDays + 1;
    final weeklyAverage = daysInMonth > 0 ? (netCashFlow / daysInMonth) * 7 : 0.0;
    final monthlyAverage = netCashFlow.toDouble();

    // Determine trend
    final firstWeek = monthlyAverage * 0.25;
    final lastWeek = monthlyAverage * 0.25; // Simplified
    CashFlowTrend trend;
    if (lastWeek > firstWeek * 1.1) {
      trend = CashFlowTrend.improving;
    } else if (lastWeek < firstWeek * 0.9) {
      trend = CashFlowTrend.declining;
    } else {
      trend = CashFlowTrend.stable;
    }

    return CashFlowSummary(
      netCashFlow: netCashFlow,
      weeklyAverage: weeklyAverage,
      monthlyAverage: monthlyAverage,
      trend: trend,
    );
  }

  List<GoalSummary> _buildGoals(List<GoalModel> goals) {
    return goals.where((g) => g.status == GoalStatus.active).map((g) {
      final account = _findAccountForGoal(g);
      final saved = account?.balance ?? 0;
      return GoalSummary(
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: saved,
        targetDate: g.targetDate ?? DateTime.now().add(const Duration(days: 365)),
      );
    }).toList();
  }

  List<DebtSummary> _buildDebts(List<DebtModel> debts) {
    return debts.where((d) => d.status == DebtStatus.active).map((d) {
      return DebtSummary(
        id: d.id,
        personName: d.personName,
        type: d.type,
        amount: d.amount,
        remainingAmount: d.remainingAmount,
        dueDate: d.dueDate,
      );
    }).toList();
  }

  List<TransactionSummary> _buildRecentTransactions(List<TransactionModel> transactions) {
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return sorted.take(20).map((t) {
      final item = t.items.isNotEmpty ? t.items.first : null;
      return TransactionSummary(
        id: t.id,
        amount: t.amount,
        type: t.type,
        category: item?.categoryId,
        merchant: t.note,
        date: t.transactionDate,
      );
    }).toList();
  }

  List<RecurringExpenseSummary> _buildRecurringExpenses(List<TransactionModel> transactions) {
    // Simplified: find merchants that appear multiple times
    final merchantCounts = <String, int>{};
    final merchantAmounts = <String, int>{};

    for (final t in transactions) {
      if (t.type == TransactionType.expense && t.note != null && t.note!.isNotEmpty) {
        final merchant = t.note!;
        merchantCounts[merchant] = (merchantCounts[merchant] ?? 0) + 1;
        merchantAmounts[merchant] = (merchantAmounts[merchant] ?? 0) + t.amount;
      }
    }

    return merchantCounts.entries
        .where((e) => e.value >= 2)
        .map(
          (e) => RecurringExpenseSummary(
            id: const Uuid().v7(),
            name: e.key,
            amount: (merchantAmounts[e.key] ?? 0) ~/ e.value,
            frequency: RecurringFrequency.monthly,
            nextDate: DateTime.now().add(const Duration(days: 30)),
          ),
        )
        .toList();
  }

  AccountModel? _findAccountForGoal(GoalModel goal) {
    // Simplified - in real implementation would look up account by goal.accountId
    return null;
  }
}
