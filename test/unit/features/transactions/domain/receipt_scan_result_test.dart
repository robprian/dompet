import 'package:dompet/features/transactions/domain/receipt_scan_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptScanResult', () {
    test('empty has no data', () {
      expect(ReceiptScanResult.empty.hasData, isFalse);
      expect(ReceiptScanResult.empty.rawText, '');
    });

    test('hasData true when amount present', () {
      const result = ReceiptScanResult(amount: 1000);
      expect(result.hasData, isTrue);
    });

    test('hasData true when merchant present', () {
      const result = ReceiptScanResult(merchant: 'Toko');
      expect(result.hasData, isTrue);
    });

    test('hasData true when note present', () {
      const result = ReceiptScanResult(note: 'notes');
      expect(result.hasData, isTrue);
    });

    test('equality works via freezed', () {
      const a = ReceiptScanResult(amount: 1, merchant: 'A');
      const b = ReceiptScanResult(amount: 1, merchant: 'A');
      expect(a, equals(b));
    });

    test('copyWith preserves unspecified fields', () {
      const a = ReceiptScanResult(amount: 5, merchant: 'A');
      final b = a.copyWith(note: 'n');
      expect(b.amount, 5);
      expect(b.merchant, 'A');
      expect(b.note, 'n');
    });
  });
}
