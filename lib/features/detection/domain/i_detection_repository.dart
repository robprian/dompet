import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';

/// Persistence boundary for the local transaction-detection pipeline.
abstract interface class IDetectionRepository {
  /// Watches candidates awaiting user review.
  Stream<List<TransactionDetectionModel>> watchPending();

  /// Count of pending review candidates.
  Future<int> countPending();

  /// Stores a fresh candidate after duplicate checks.
  Future<void> saveCandidate(TransactionDetectionModel model);

  /// Checks whether the normalized fingerprint was already recorded.
  Future<bool> hasFingerprint(String fingerprint);

  /// Checks for a very similar recent candidate (amount + party + type).
  Future<bool> hasRecentSimilar({
    required String sourcePackage,
    required int amount,
    required DetectionTransactionType type,
    required String? merchant,
    required String? counterparty,
    required DateTime since,
  });

  /// Marks a candidate as imported or ignored, storing review choices.
  Future<void> resolveCandidate({
    required String id,
    required DetectionStatus status,
    String? accountId,
    String? categoryId,
  });

  /// Learns (or reinforces) a merchant->category mapping from review.
  Future<void> learnMerchantCategory({required String merchant, required String categoryId});

  /// Returns the learned category id for a merchant, if any.
  Future<String?> getLearnedCategory(String merchant);

  /// Registers a salary observation and returns the updated profile.
  Future<void> recordSalary({required int amount, required int dayOfMonth, required double confidence});

  /// True when a salary-like income was detected previously.
  Future<bool> hasSalaryRecord();

  /// Reads a detection-related settings value.
  Future<String?> getSetting(String key);

  /// Persists a detection-related settings value.
  Future<void> setSetting(String key, String value);
}
