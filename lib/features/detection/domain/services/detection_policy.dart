/// Pure policy mapping for the confidence-driven import behavior.
class DetectionPolicy {
  /// Creates the policy from stored settings.
  const DetectionPolicy({
    required this.enabled,
    required this.autoImportEnabled,
    required this.autoImportThreshold,
    required this.salaryDetectionEnabled,
  });

  /// Loads the policy from raw settings values.
  factory DetectionPolicy.fromSettings(Map<String, String?> raw) {
    return DetectionPolicy(
      enabled: _parseBool(raw['detectionEnabled'], true),
      autoImportEnabled: _parseBool(raw['detectionAutoImportEnabled'], true),
      autoImportThreshold: _parseDouble(raw['detectionAutoImportThreshold'], 0.9),
      salaryDetectionEnabled: _parseBool(raw['salaryDetectionEnabled'], true),
    );
  }

  /// Master switch for notification detection.
  final bool enabled;

  /// Whether high-confidence candidates import automatically.
  final bool autoImportEnabled;

  /// Confidence needed for automatic import (default 0.90).
  final double autoImportThreshold;

  /// Whether salary detection is active.
  final bool salaryDetectionEnabled;

  /// True when a candidate is eligible for automatic ledger import.
  bool shouldAutoImport(double confidence) {
    if (!enabled || !autoImportEnabled) return false;
    return confidence >= autoImportThreshold;
  }

  /// True when a candidate deserves storage for review.
  bool shouldReview(double confidence) => confidence >= 0.5;

  /// Defaults used when no settings exist yet.
  static const DetectionPolicy defaults = DetectionPolicy(
    enabled: true,
    autoImportEnabled: true,
    autoImportThreshold: 0.9,
    salaryDetectionEnabled: true,
  );

  static bool _parseBool(String? value, bool fallback) {
    if (value == null) return fallback;
    return value.toLowerCase() == 'true';
  }

  static double _parseDouble(String? value, double fallback) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed <= 0 || parsed > 1) return fallback;
    return parsed;
  }
}
