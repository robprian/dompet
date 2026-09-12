import 'package:dompet/features/transactions/data/receipt_scanner_service.dart';
import 'package:riverpod/riverpod.dart';

/// Provides the receipt scanner used by the transaction form.
///
/// Provides the on-device OCR scanner used by the transaction form.
final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return MlKitReceiptScannerService();
});
