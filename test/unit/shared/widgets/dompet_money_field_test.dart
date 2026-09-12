import 'package:dompet/core/utils/number_format_service.dart';
import 'package:dompet/shared/widgets/dompet_money_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyInputFormatter', () {
    final formatter = MoneyInputFormatter(const NumberFormatService('id_ID'));

    test('groups integer input using the selected locale', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1000000', selection: TextSelection.collapsed(offset: 7)),
      );

      expect(result.text, '1.000.000');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('preserves a decimal separator while typing', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '1.000'),
        const TextEditingValue(text: '1000,', selection: TextSelection.collapsed(offset: 5)),
      );

      expect(result.text, '1.000,');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('keeps the cursor next to the edited digits after grouping', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '1.000'),
        const TextEditingValue(text: '10000', selection: TextSelection.collapsed(offset: 4)),
      );

      expect(result.text, '10.000');
      expect(result.selection.baseOffset, 5);
    });

    test('rejects a minus sign unless negative values are enabled', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '-100', selection: TextSelection.collapsed(offset: 4)),
      );

      expect(result.text, '100');
    });
  });
}
