/// Salary-detection domain service (pure, no IO).
library;

/// Single observed income event used for salary history.
class SalaryObservation {
  /// Creates an income observation.
  const SalaryObservation({required this.amount, required this.occurredAt});

  /// Gross income amount in minor units.
  final int amount;

  /// When the income landed.
  final DateTime occurredAt;
}

/// Result of a salary assessment.
class SalaryAssessment {
  /// Creates an assessment.
  const SalaryAssessment({required this.score, required this.reason});

  /// 0.0-1.0 salary likelihood.
  final double score;

  /// Human-readable reason for the score.
  final String reason;

  /// Whether the score passes the auto-classification bar.
  bool get isHighConfidence => score >= 0.9;

  /// Whether the score warrants a review prompt.
  bool get isLikely => score >= 0.7;
}

/// Detects salary income from notification keywords and historical patterns.
class SalaryDetector {
  /// Creates the detector with optional history window settings.
  const SalaryDetector({
    this.monthsLookback = 3,
    this.dayToleranceDays = 2,
    this.strongKeywords = const {
      'gaji', 'salary', 'payroll', 'upah', 'thr', 'gaji bulanan', 'gaji karyawan', 'salary credited', 'payroll credited',
    },
    this.mediumKeywords = const {
      'dana masuk', 'transfer masuk', 'diterima', 'incoming transfer', 'kredit', 'deposit', 'top up',
    },
  });

  /// How many prior months to inspect for a recurring amount.
  final int monthsLookback;

  /// Allowed day-of-month deviation for a recurring hit.
  final int dayToleranceDays;

  /// Keywords that strongly indicate salary.
  final Set<String> strongKeywords;

  /// Keywords that weakly indicate salary.
  final Set<String> mediumKeywords;

  /// Assesses the income event against keyword signals and [history].
  SalaryAssessment assess({
    required String sourceText,
    required int amount,
    required DateTime occurredAt,
    required List<SalaryObservation> history,
  }) {
    final text = sourceText.toLowerCase();
    var score = 0.0;

    final strongHit = strongKeywords.where(text.contains);
    if (strongHit.isNotEmpty) score += 0.6;

    final mediumHit = mediumKeywords.where(text.contains);
    if (mediumHit.isNotEmpty && strongHit.isEmpty) score += 0.25;

    final recurring = _findRecurringMatch(amount, occurredAt, history);
    if (recurring != null) score += 0.3;
    if (recurring == null && score > 0.55) score -= 0.15;

    if (score > 0.95) score = 0.95;
    if (score < 0) score = 0;
    score = (score * 100).round() / 100;

    final reason = score >= 0.7
        ? 'salary_recurring_or_keyword'
        : score >= 0.5
            ? 'salary_uncertain'
            : 'salary_unlikely';
    return SalaryAssessment(score: score, reason: reason);
  }

  SalaryObservation? _findRecurringMatch(int amount, DateTime occurredAt, List<SalaryObservation> history) {
    if (history.isEmpty) return null;
    final cutoff = DateTime.utc(
      occurredAt.year,
      occurredAt.month - monthsLookback,
      occurredAt.day,
    );
    for (final observation in history) {
      if (observation.amount != amount) continue;
      if (observation.occurredAt.isBefore(cutoff)) continue;
      final dayDiff = (observation.occurredAt.day - occurredAt.day).abs();
      if (dayDiff <= dayToleranceDays) return observation;
    }
    return null;
  }
}
