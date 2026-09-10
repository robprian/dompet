/// Privacy filter for AI context data.
library;

import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';

/// Configuration for what data to share with external AI providers.
class PrivacyConfig {
  const PrivacyConfig({
    this.shareTransactionDetails = false,
    this.shareMerchantNames = false,
    this.shareCategories = true,
    this.shareBudgetInfo = true,
    this.shareAccountBalances = false,
    this.shareIncomeInfo = false,
    this.shareGoals = false,
    this.shareDebts = false,
    this.anonymizeMerchants = true,
    this.anonymizeAccountNames = true,
  });

  /// Whether to include full transaction details (amount, date, notes).
  final bool shareTransactionDetails;

  /// Whether to include merchant names (if false, they'll be anonymized).
  final bool shareMerchantNames;

  /// Whether to include category information.
  final bool shareCategories;

  /// Whether to include budget information.
  final bool shareBudgetInfo;

  /// Whether to include account balances.
  final bool shareAccountBalances;

  /// Whether to include income information.
  final bool shareIncomeInfo;

  /// Whether to include savings goals.
  final bool shareGoals;

  /// Whether to include debt information.
  final bool shareDebts;

  /// Whether to anonymize merchant names (replace with category).
  final bool anonymizeMerchants;

  /// Whether to anonymize account names (use generic labels).
  final bool anonymizeAccountNames;

  /// Default privacy-preserving configuration.
  static const PrivacyConfig strict = PrivacyConfig();

  /// Balanced configuration for useful insights with reasonable privacy.
  static const PrivacyConfig balanced = PrivacyConfig(
    shareTransactionDetails: true,
    shareIncomeInfo: true,
    shareGoals: true,
    shareDebts: true,
  );

  /// Full sharing configuration for maximum AI utility.
  static const PrivacyConfig permissive = PrivacyConfig(
    shareTransactionDetails: true,
    shareMerchantNames: true,
    shareAccountBalances: true,
    shareIncomeInfo: true,
    shareGoals: true,
    shareDebts: true,
    anonymizeMerchants: false,
    anonymizeAccountNames: false,
  );
}

/// Applies privacy filtering to an advisor context.
class PrivacyFilter {
  const PrivacyFilter(this.config);

  final PrivacyConfig config;

  /// Filters the context based on privacy configuration.
  AdvisorContext filter(AdvisorContext context) {
    return AdvisorContext(
      incomeSummary: config.shareIncomeInfo ? context.incomeSummary : const IncomeSummary(total: 0, byCategory: {}),
      expenseSummary: config.shareTransactionDetails
          ? context.expenseSummary
          : const ExpenseSummary(total: 0, byCategory: {}),
      budgetSummary: config.shareBudgetInfo ? context.budgetSummary : const BudgetSummary(budgets: []),
      categorySummary: config.shareCategories ? context.categorySummary : const CategorySummary(byCategory: {}),
      cashFlow: context.cashFlow,
      goals: config.shareGoals ? context.goals : [],
      debts: config.shareDebts ? context.debts : [],
      recentTransactions: _filterTransactions(context.recentTransactions),
      recurringExpenses: _filterRecurring(context.recurringExpenses),
    );
  }

  List<TransactionSummary> _filterTransactions(List<TransactionSummary> transactions) {
    if (!config.shareTransactionDetails) {
      return transactions
          .map(
            (t) => TransactionSummary(
              id: t.id,
              amount: config.shareTransactionDetails ? t.amount : 0,
              type: t.type,
              category: config.shareCategories ? t.category : null,
              merchant: _anonymizeMerchant(t.merchant),
              date: t.date,
            ),
          )
          .toList();
    }
    return transactions
        .map(
          (t) => TransactionSummary(
            id: t.id,
            amount: t.amount,
            type: t.type,
            category: config.shareCategories ? t.category : null,
            merchant: _anonymizeMerchant(t.merchant),
            date: t.date,
          ),
        )
        .toList();
  }

  List<RecurringExpenseSummary> _filterRecurring(List<RecurringExpenseSummary> expenses) {
    return expenses
        .map(
          (e) => RecurringExpenseSummary(
            id: e.id,
            name: config.anonymizeMerchants ? 'Recurring' : e.name,
            amount: config.shareTransactionDetails ? e.amount : 0,
            frequency: e.frequency,
            nextDate: e.nextDate,
          ),
        )
        .toList();
  }

  String? _anonymizeMerchant(String? merchant) {
    if (merchant == null) return null;
    if (!config.anonymizeMerchants) return merchant;
    return 'Merchant';
  }
}
