import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/advisor/domain/ai/advisor_provider_registry.dart';
import 'package:dompet/features/advisor/domain/ai/ai_context_builder.dart';
import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:dompet/features/advisor/domain/ai/local_rule_provider.dart';
import 'package:dompet/features/advisor/domain/ai/openai_compatible_provider.dart';
import 'package:dompet/features/advisor/domain/ai/privacy_filter.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

void main() {
  group('LocalRuleProvider', () {
    test('is available without any API key', () async {
      final provider = LocalRuleProvider();
      expect(provider.id, 'local-rules');
      expect(provider.requiresApiKey, isFalse);
      expect(await provider.isAvailable(), isTrue);
    });

    test('analyzes a context and returns recommendations', () async {
      final provider = LocalRuleProvider();
      final context = _buildContext();
      final response = await provider.analyze(context);
      expect(response.recommendations, isNotEmpty);
    });
  });

  group('AdvisorProviderRegistry', () {
    test('contains all built-in provider IDs', () {
      expect(
        AdvisorProviderRegistry.providerIds,
        containsAll(['local-rules', 'openai', 'anthropic', 'gemini', 'openai-compatible', 'custom']),
      );
    });

    test('creates local provider by default', () {
      const registry = AdvisorProviderRegistry();
      final provider = registry.createProvider(const ProviderConfig(id: 'local-rules'));
      expect(provider.id, 'local-rules');
      expect(provider.name, contains('Local'));
    });

    test('falls back to local provider for unknown IDs', () {
      const registry = AdvisorProviderRegistry();
      final provider = registry.createProvider(const ProviderConfig(id: 'unknown'));
      expect(provider.id, 'local-rules');
    });

    test('creates OpenAI-compatible provider with config', () {
      const registry = AdvisorProviderRegistry();
      final provider = registry.createProvider(
        const ProviderConfig(
          id: 'openai-compatible',
          baseUrl: 'https://example.com/v1',
          apiKey: 'test-key',
          model: 'test-model',
        ),
      );
      expect(provider, isA<OpenAICompatibleProvider>());
      expect(provider.requiresApiKey, isTrue);
    });
  });

  group('PrivacyFilter', () {
    test('strict mode strips sensitive data', () {
      const filter = PrivacyFilter(PrivacyConfig.strict);
      final context = _buildContext();
      final filtered = filter.filter(context);
      expect(filtered.incomeSummary.total, 0);
      expect(filtered.expenseSummary.total, 0);
      expect(filtered.goals, isEmpty);
      expect(filtered.debts, isEmpty);
    });

    test('balanced mode keeps aggregates but anonymizes merchants', () {
      const filter = PrivacyFilter(PrivacyConfig.balanced);
      final context = _buildContext();
      final filtered = filter.filter(context);
      expect(filtered.incomeSummary.total, greaterThan(0));
      expect(filtered.recentTransactions.every((t) => t.merchant != null), isTrue);
    });
  });

  group('AIContextBuilder', () {
    test('builds context from application data', () {
      final builder = AIContextBuilder();
      final context = builder.build(
        transactions: _transactions(),
        accounts: _accounts(),
        budgets: _budgets(),
        goals: _goals(),
        debts: _debts(),
        budgetSpent: {'b1': 800000},
      );
      expect(context.incomeSummary.total, greaterThan(0));
      expect(context.expenseSummary.total, greaterThan(0));
      expect(context.budgetSummary.budgets, hasLength(1));
      expect(context.goals, hasLength(1));
      expect(context.debts, hasLength(1));
      expect(context.recentTransactions, isNotEmpty);
    });

    test('applies privacy filter when configured', () {
      final builder = AIContextBuilder(privacyFilter: const PrivacyFilter(PrivacyConfig.strict));
      final context = builder.build(
        transactions: _transactions(),
        accounts: _accounts(),
        budgets: _budgets(),
        goals: _goals(),
        debts: _debts(),
        budgetSpent: {'b1': 800000},
      );
      expect(context.incomeSummary.total, 0);
      expect(context.expenseSummary.total, 0);
      expect(context.goals, isEmpty);
    });
  });

  group('OpenAICompatibleProvider', () {
    test('requires API key and config', () {
      final provider = OpenAICompatibleProvider(
        config: const OpenAICompatibleConfig(
          baseUrl: 'https://example.com/v1',
          apiKey: 'test-key',
          model: 'test-model',
        ),
      );
      expect(provider.requiresApiKey, isTrue);
      expect(provider.name, contains('OpenAI Compatible'));
    });

    test('isAvailable returns false when API is unreachable', () async {
      final provider = OpenAICompatibleProvider(
        config: const OpenAICompatibleConfig(
          baseUrl: 'http://localhost:1/v1',
          apiKey: 'test-key',
          model: 'test-model',
        ),
      );
      expect(await provider.isAvailable(), isFalse);
    });
  });
}

AdvisorContext _buildContext() {
  final now = _now;
  return AdvisorContext(
    incomeSummary: const IncomeSummary(total: 10000000, byCategory: {'salary': 10000000}),
    expenseSummary: const ExpenseSummary(total: 6000000, byCategory: {'food': 2500000}),
    budgetSummary: const BudgetSummary(
      budgets: [BudgetStatus(id: 'b1', name: 'Makan', amount: 1000000, spent: 800000, category: 'food')],
    ),
    categorySummary: const CategorySummary(byCategory: {'food': 2500000}),
    cashFlow: const CashFlowSummary(
      netCashFlow: 4000000,
      weeklyAverage: 1000000,
      monthlyAverage: 4000000,
      trend: CashFlowTrend.improving,
    ),
    goals: [
      GoalSummary(id: 'g1', name: 'Liburan', targetAmount: 5000000, currentAmount: 2000000, targetDate: DateTime(2027)),
    ],
    debts: [
      DebtSummary(
        id: 'd1',
        personName: 'Budi',
        type: DebtType.debt,
        amount: 3000000,
        remainingAmount: 1500000,
        dueDate: DateTime(2027),
      ),
    ],
    recentTransactions: [
      TransactionSummary(
        id: 't1',
        amount: 250000,
        type: TransactionType.expense,
        category: 'food',
        merchant: 'Kopi ABC',
        date: now,
      ),
    ],
    recurringExpenses: [
      RecurringExpenseSummary(
        id: 'r1',
        name: 'Netflix',
        amount: 149000,
        frequency: RecurringFrequency.monthly,
        nextDate: DateTime(2027),
      ),
    ],
  );
}

List<TransactionModel> _transactions() {
  final now = _now;
  return [
    TransactionModel(
      id: 't1',
      accountId: 'a1',
      type: TransactionType.income,
      amount: 10000000,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
      items: [TransactionItemModel(id: 'i1', transactionId: 't1', amount: 10000000, createdAt: now, updatedAt: now)],
    ),
    TransactionModel(
      id: 't2',
      accountId: 'a1',
      type: TransactionType.expense,
      amount: 2500000,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
      items: [TransactionItemModel(id: 'i2', transactionId: 't2', amount: 2500000, createdAt: now, updatedAt: now)],
    ),
  ];
}

List<AccountModel> _accounts() {
  final now = _now;
  return [
    AccountModel(id: 'a1', name: 'BCA', type: AccountType.assets, balance: 5000000, createdAt: now, updatedAt: now),
  ];
}

List<BudgetModel> _budgets() {
  final now = _now;
  return [
    BudgetModel(
      id: 'b1',
      name: 'Makan',
      amount: 1000000,
      period: BudgetPeriod.monthly,
      startDate: DateTime(now.year, now.month),
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

List<GoalModel> _goals() {
  final now = _now;
  return [
    GoalModel(
      id: 'g1',
      accountId: 'a1',
      name: 'Liburan',
      targetAmount: 5000000,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

List<DebtModel> _debts() {
  final now = _now;
  return [
    DebtModel(
      id: 'd1',
      personName: 'Budi',
      type: DebtType.debt,
      amount: 3000000,
      remainingAmount: 1500000,
      status: DebtStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
