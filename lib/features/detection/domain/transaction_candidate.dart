import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_candidate.freezed.dart';

/// Normalized, local-only transaction candidate produced by a parser.
@freezed
abstract class TransactionCandidate with _$TransactionCandidate {
  const factory TransactionCandidate({
    required String fingerprint,
    required int amount,
    required DetectionTransactionType type,
    required PaymentMethod method,
    required double confidence,
    required ConfidenceTier confidenceTier,
    required DateTime occurredAt,
    required String parserVersion,
    required String sourcePackage,
    String? merchant,
    String? counterparty,
    String? referenceId,
    String? maskedAccount,
    @Default(false) bool likelySalary,
    String? categoryHint,
    @Default('') String sourceText,
  }) = _TransactionCandidate;

  const TransactionCandidate._();

  /// True when the candidate is safe for automatic import.
  bool get canAutoImport => confidence >= 0.90;

  /// Creates a stable duplicate key from normalized fields.
  static String makeFingerprint({
    required String sourcePackage,
    required int amount,
    required DetectionTransactionType type,
    required String? merchant,
    required String? referenceId,
    required DateTime occurredAt,
  }) {
    final bucket = occurredAt.toUtc().millisecondsSinceEpoch ~/ 60000;
    return [
      sourcePackage.trim().toLowerCase(),
      amount,
      type.name,
      merchant?.trim().toLowerCase() ?? '',
      referenceId?.trim().toLowerCase() ?? '',
      bucket,
    ].join('|');
  }
}

/// Contract implemented by each notification parser.
abstract interface class NotificationTransactionParser {
  /// Stable parser version string reported on every candidate.
  String get parserVersion;

  /// Parses a notification, returning null when it is not recognized.
  TransactionCandidate? parse(NotificationPayload payload);
}
