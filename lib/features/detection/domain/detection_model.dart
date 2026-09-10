import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection_model.freezed.dart';

/// Persisted detection candidate surfaced to the review UI.
@freezed
abstract class TransactionDetectionModel with _$TransactionDetectionModel {
  const factory TransactionDetectionModel({
    required String id,
    required String fingerprint,
    required String sourcePackage,
    required DetectionTransactionType type,
    required int amount,
    required double confidence,
    required ConfidenceTier confidenceTier,
    required PaymentMethod method,
    required String parserVersion,
    required DetectionStatus status,
    required DateTime occurredAt,
    required DateTime createdAt,
    String? merchant,
    String? counterparty,
    String? referenceId,
    String? categoryId,
    String? accountId,
  }) = _TransactionDetectionModel;

  const TransactionDetectionModel._();

  /// Display label of the payment channel.
  String get methodLabel => switch (method) {
    PaymentMethod.qris => 'QRIS',
    PaymentMethod.bank => 'Bank Transfer',
    PaymentMethod.ewallet => 'E-Wallet',
    PaymentMethod.card => 'Card',
    PaymentMethod.cash => 'Cash',
    PaymentMethod.other => 'Other',
  };

  /// Primary party name for display and search.
  String? get partyName => merchant ?? counterparty;
}

/// Salary hypothesis derived from recurring income patterns.
@freezed
abstract class SalaryProfileModel with _$SalaryProfileModel {
  const factory SalaryProfileModel({
    required String id,
    required int amount,
    required int dayOfMonth,
    required double averageConfidence,
    required int occurrenceCount,
    DateTime? lastDetectedAt,
  }) = _SalaryProfileModel;

  const SalaryProfileModel._();
}
