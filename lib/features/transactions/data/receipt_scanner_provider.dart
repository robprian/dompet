import 'package:dompet/features/transactions/data/receipt_scanner_service.dart';
import 'package:riverpod/riverpod.dart';

/// Provides the receipt scanner used by the transaction form.
///
/// Defaults to the on-device ML Kit scanner. Tests can override this with a
/// fake implementation to avoid touching platform plugins.
final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return MlKitReceiptScannerService();
});
