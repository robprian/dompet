import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/advisor_engine.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/advisor/domain/allocation_engine.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now().toUtc();

TransactionModel expense(int amount, {DateTime? date}) {
  return TransactionModel(
    id: 't-$amount-${date ?? _now}',
    accountId: 'a1',
    type: TransactionType.expense,
    amount: amount,
    transactionDate: date ?? _now,
    createdAt: _now,
    updatedAt: _now,
  );
}

BudgetModel budget(String id, String name, int amount) {
  return BudgetModel(
    id: id,
    name: name,
    amount: amount,
    period: BudgetPeriod.monthly,
    startDate: DateTime(_now.year, _now.month),
    createdAt: _now,
    updatedAt: _now,
  );
}

AdvisorSnapshot snapshot({
  int income = 10000000,
  int expense = 5000000,
  List<TransactionModel> transactions = const [],
  List<BudgetModel> budgets = const [],
  Map<String, int> budgetSpent = const {},
  int goalsTarget = 0,
  int goalsSaved = 0,
}) {
  return AdvisorSnapshot(
    income: income,
    expense: expense,
    accounts: const [],
    transactions: transactions,
    budgets: budgets,
    budgetSpent: budgetSpent,
    goalsTarget: goalsTarget,
    goalsSaved: goalsSaved,
    debtRemaining: 0,
  );
}

void main() {
  group('AllocationEngine', () {
    test('allocates income across default buckets', () {
      final plan = AllocationEngine().allocate(10000000);
      expect(plan.income, 10000000);
      expect(plan.needs, 5000000);
      expect(plan.savings, 2000000);
      expect(plan.debt, 1500000);
      expect(plan.lifestyle, 1000000);
      expect(plan.buffer, 500000);
      expect(plan.total, 10000000);
    });

    test('supports configurable allocation rules', () {
      const config = AllocationConfig(
        needsPercent: 40,
        savingsPercent: 30,
        debtPercent: 10,
        lifestylePercent: 10,
        bufferPercent: 10,
      );
      final plan = AllocationEngine(config: config).allocate(10000000);
      expect(plan.needs, 4000000);
      expect(plan.savings, 3000000);
      expect(plan.total, 10000000);
    });

    test('encodes and parses allocation config', () {
      const config = AllocationConfig(
        needsPercent: 40,
        savingsPercent: 30,
        debtPercent: 10,
        lifestylePercent: 10,
        bufferPercent: 10,
      );
      expect(AllocationConfig.fromEncoded(config.encode()), config);
      expect(AllocationConfig.fromEncoded(null), const AllocationConfig());
      expect(AllocationConfig.fromEncoded('bogus'), const AllocationConfig());
      expect(AllocationConfig.fromEncoded('50|20|15'), const AllocationConfig());
    });

    test('handles zero income safely', () {
      final plan = AllocationEngine().allocate(0);
      expect(plan.total, 0);
    });
  });

  group('AdvisorEngine', () {
    test('emits an allocation recommendation for income', () {
      final recommendations = AdvisorEngine().analyze(snapshot());
      expect(
        recommendations.where((r) => r.type == AdvisorRecommendationType.salaryAllocation),
        hasLength(1),
      );
      expect(recommendations.first.isSalaryRelated, isTrue);
    });

    test('flags budgets that are over or almost spent', () {
      final budgets = [budget('b1', 'Makan', 1000000), budget('b2', 'Transport', 500000)];
      final recommendations = AdvisorEngine().analyze(
        snapshot(budgets: budgets, budgetSpent: {'b1': 1200000, 'b2': 450000}),
      );
      final over = recommendations.where((r) => r.relatedName == 'Makan');
      expect(over, hasLength(1));
      expect(over.first.severity, AdvisorSeverity.warning);
      final almost = recommendations.where((r) => r.relatedName == 'Transport');
      expect(almost, hasLength(1));
      expect(almost.first.amount, 50000);
    });

    test('warns on negative cash flow', () {
      final recommendations = AdvisorEngine().analyze(snapshot(income: 5000000, expense: 7000000));
      expect(
        recommendations.any((r) => r.type == AdvisorRecommendationType.cashFlow),
        isTrue,
      );
    });

    test('warns on low savings rate', () {
      final recommendations = AdvisorEngine().analyze(snapshot(income: 10000000, expense: 9500000));
      expect(
        recommendations.any((r) => r.type == AdvisorRecommendationType.savingsRate),
        isTrue,
      );
    });

    test('detects unusually large transactions', () {
      final transactions = [expense(50000), expense(60000), expense(55000), expense(900000)];
      final recommendations = AdvisorEngine().analyze(snapshot(transactions: transactions));
      final large = recommendations.where((r) => r.type == AdvisorRecommendationType.largeTransaction);
      expect(large, hasLength(1));
      expect(large.first.amount, 900000);
    });

    test('tracks remaining goal targets', () {
      final recommendations = AdvisorEngine().analyze(snapshot(goalsTarget: 5000000, goalsSaved: 2000000));
      final goals = recommendations.where((r) => r.amount == 3000000);
      expect(goals, isNotEmpty);
    });

    test('stays quiet for healthy finances', () {
      final recommendations = AdvisorEngine().analyze(snapshot(income: 10000000, expense: 4000000));
      expect(
        recommendations.where((r) => r.severity == AdvisorSeverity.warning),
        isEmpty,
      );
    });
  });
}
