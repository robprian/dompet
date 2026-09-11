import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_scan_result.freezed.dart';

/// Structured fields extracted from a scanned receipt or payment screenshot.
///
/// All fields are best-effort: OCR is noisy, so callers must present the
/// result as an editable suggestion rather than committing it directly.
@freezed
abstract class ReceiptScanResult with _$ReceiptScanResult {
  /// Creates a [ReceiptScanResult].
  const factory ReceiptScanResult({
    /// Total amount detected on the receipt, if any.
    double? amount,

    /// Merchant or counterparty name, if detected.
    String? merchant,

    /// Transaction date detected on the receipt, if any.
    DateTime? date,

    /// Free-text note assembled from the receipt header lines.
    String? note,

    /// Raw OCR text, kept for debugging and optional AI refinement.
    @Default('') String rawText,
  }) = _ReceiptScanResult;

  const ReceiptScanResult._();

  /// A result with no recognised fields.
  static const empty = ReceiptScanResult();

  /// Whether any actionable field was recognised.
  bool get hasData => amount != null || merchant != null || note != null;
}
