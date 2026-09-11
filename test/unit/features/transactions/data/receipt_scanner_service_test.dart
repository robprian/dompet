import 'package:dompet/features/transactions/data/receipt_scanner_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptTextParser', () {
    test('returns empty result for blank text', () {
      final result = ReceiptTextParser.parse('   ');
      expect(result.hasData, isFalse);
      expect(result.amount, isNull);
    });

    test('extracts amount from a total line with id_ID grouping', () {
      const text = '''
KOPI KENANGAN
Tanggal: 12/09/2026
Total: Rp 25.500
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.amount, 25500);
    });

    test('extracts amount from a total line with en_US grouping', () {
      const text = '''
STARBUCKS
Total: \$12.50
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.amount, 12.5);
    });

    test('prefers a total keyword over other amounts', () {
      const text = '''
Item A 10.000
Item B 20.000
Grand Total 30.000
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.amount, 30000);
    });

    test('falls back to the largest amount when no total keyword exists', () {
      const text = '''
Indomaret
Air Mineral 5.000
Roti 12.000
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.amount, 12000);
    });

    test('extracts a merchant from the first meaningful line', () {
      const text = '''
ALFAMART
Total: 15.000
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.merchant, 'ALFAMART');
    });

    test('extracts a two-digit year date', () {
      const text = '''
Toko
Tanggal 01/02/26
Total 9.000
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.date, DateTime(2026, 2, 1));
    });

    test('ignores invalid dates', () {
      const text = '''
Toko
Tanggal 45/13/2026
Total 9.000
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.date, isNull);
    });

    test('keeps raw text for debugging', () {
      const text = 'Toko A\nTotal 1.000';
      final result = ReceiptTextParser.parse(text);
      expect(result.rawText, contains('Toko A'));
    });

    test('hasData is true when only merchant is recognised', () {
      const text = 'MERCHANT ONLY';
      final result = ReceiptTextParser.parse(text);
      expect(result.hasData, isTrue);
      expect(result.merchant, 'MERCHANT ONLY');
    });
  });
}
