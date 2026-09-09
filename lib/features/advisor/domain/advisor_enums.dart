/// Domain events emitted by the local advisor pipeline.
enum AdvisorEventType {
  /// A transaction was created (manual or imported).
  transactionCreated,

  /// Income was detected.
  incomeDetected,

  /// A likely salary payment was detected.
  salaryDetected,

  /// A budget crossed its alert threshold.
  budgetThresholdReached,

  /// An unusually large expense was detected.
  largeTransactionDetected,

  /// Spending deviated from the historical pattern.
  unusualSpendingDetected,

  /// A recurring expense was identified.
  recurringExpenseDetected,
}

/// Severity level of a recommendation.
enum AdvisorSeverity { info, success, warning }

/// Kind of recommendation produced by the engine.
enum AdvisorRecommendationType {
  /// Salary received with allocation guidance.
  salaryAllocation,

  /// Budget close to or over its limit.
  budget,

  /// Spending over the historical pattern.
  overspending,

  /// A single large expense.
  largeTransaction,

  /// Savings rate below a healthy level.
  savingsRate,

  /// Cash flow was negative for the period.
  cashFlow,

  /// A recurring expense was identified.
  recurringExpense,
}
