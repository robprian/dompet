import 'package:dompet/core/utils/number_format_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberFormatService', () {
    test('formats integers with grouping per locale', () {
      expect(const NumberFormatService('en_US').formatInt(1234567), '1,234,567');
      expect(const NumberFormatService('id_ID').formatInt(1234567), '1.234.567');
    });

    test('detects locale separators', () {
      const id = NumberFormatService('id_ID');
      expect(id.groupSeparator, '.');
      expect(id.decimalSeparator, ',');

      const us = NumberFormatService('en_US');
      expect(us.groupSeparator, ',');
      expect(us.decimalSeparator, '.');
    });

    test('formatNumericString keeps fraction with locale decimal separator', () {
      expect(const NumberFormatService('en_US').formatNumericString('50000.5'), '50,000.5');
      expect(const NumberFormatService('id_ID').formatNumericString('50000.5'), '50.000,5');
      final fr = const NumberFormatService('fr_FR');
      expect(
        fr.formatNumericString('50000.5'),
        '50${fr.groupSeparator}000${fr.decimalSeparator}5',
      );
    });

    test('formatNumericString handles leading/empty integer parts', () {
      expect(const NumberFormatService('en_US').formatNumericString('.5'), '0.5');
      expect(const NumberFormatService('id_ID').formatNumericString('.5'), '0,5');
    });

    test('formatNumericString falls back to raw for invalid input', () {
      expect(const NumberFormatService('en_US').formatNumericString('abc'), 'abc');
      expect(const NumberFormatService('en_US').formatNumericString(''), '0');
    });

    test('formatInt handles large and zero values', () {
      const us = NumberFormatService('en_US');
      expect(us.formatInt(0), '0');
      expect(us.formatInt(1000000), '1,000,000');
    });

    test('formatCurrency includes symbol and precision', () {
      final formatted = const NumberFormatService('id_ID').formatCurrency(
        1500,
        symbol: 'Rp',
        precision: 0,
      );
      expect(formatted, contains('Rp'));
      expect(formatted, contains('1.500'));
    });

    test('system locale follows the device locale', () {
      expect(const NumberFormatService(NumberFormatService.systemLocale).locale, isNull);
    });

    test('normalizeGrouping matches formatNumericString', () {
      const s = NumberFormatService('id_ID');
      expect(s.normalizeGrouping('1000000'), s.formatNumericString('1000000'));
    });

    test('parse handles grouping-only values as integers', () {
      expect(const NumberFormatService('id_ID').parse('25.500'), 25500);
      expect(const NumberFormatService('en_US').parse('25,500'), 25500);
      expect(const NumberFormatService('id_ID').parse('1.234.567'), 1234567);
    });

    test('parse handles explicit decimals', () {
      expect(const NumberFormatService('en_US').parse('12.50'), 12.5);
      expect(const NumberFormatService('id_ID').parse('12,50'), 12.5);
      expect(const NumberFormatService('id_ID').parse('1.234,56'), 1234.56);
      expect(const NumberFormatService('en_US').parse('1,234.56'), 1234.56);
    });

    test('parse returns null for unparseable input', () {
      expect(const NumberFormatService('en_US').parse(''), isNull);
      expect(const NumberFormatService('en_US').parse('abc'), isNull);
    });
  });
}
