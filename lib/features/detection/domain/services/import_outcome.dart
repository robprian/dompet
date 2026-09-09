/// Outcome classification of processing one notification.
enum ImportOutcomeType {
  /// Candidate was auto-imported into the ledger.
  imported,

  /// Candidate stored for review.
  review,

  /// Candidate below the confidence floor and discarded.
  discarded,

  /// Duplicate of an existing detection or transaction.
  duplicate,
}

/// Result of processing one notification.
class ImportOutcome {
  /// Creates an outcome.
  const ImportOutcome({required this.type, this.detectionId, this.amount, this.confidence, this.isSalary});

  /// What happened.
  final ImportOutcomeType type;

  /// Stored detection row id when applicable.
  final String? detectionId;

  /// Detected amount.
  final int? amount;

  /// Detection confidence.
  final double? confidence;

  /// Whether the pipeline believes this is salary.
  final bool? isSalary;
}
