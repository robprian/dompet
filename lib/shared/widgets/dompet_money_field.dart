import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/core/utils/number_format_service.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text input formatter that inserts locale-aware thousands separators while
/// the user types, preserving any in-progress decimal part.
///
/// This is the single source of truth for money fields so every amount input
/// in the app formats consistently with the user's `numberFormat` setting.
class MoneyInputFormatter extends TextInputFormatter {
  /// Creates a formatter bound to a [NumberFormatService].
  MoneyInputFormatter(this.service, {this.allowNegative = false});

  /// The locale-aware formatter used to group digits.
  final NumberFormatService service;

  /// Whether a leading minus sign is accepted.
  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;

    // Allow a single leading minus sign for liability/negative balances.
    final isNegative = allowNegative && raw.startsWith('-');
    final normalized = raw.replaceAll(service.groupSeparator, '').replaceAll(service.decimalSeparator, '.');
    final digitsOnly = normalized.replaceAll(RegExp('[^0-9.]'), '');
    if (digitsOnly.isEmpty) {
      return isNegative ? const TextEditingValue(text: '-') : TextEditingValue.empty;
    }

    // Keep at most one decimal point.
    final dotIndex = digitsOnly.indexOf('.');
    final hasDecimal = dotIndex >= 0;
    // Ignore a second decimal point.
    final cleaned = hasDecimal
        ? '${digitsOnly.substring(0, dotIndex + 1)}${digitsOnly.substring(dotIndex + 1).replaceAll('.', '')}'
        : digitsOnly;

    final formatted = service.formatNumericString(cleaned);
    final text = '${isNegative ? '-' : ''}$formatted';
    final cursorOffset = newValue.selection.baseOffset.clamp(0, raw.length);
    final rawBeforeCursor = raw.substring(0, cursorOffset);
    final cursorInput = rawBeforeCursor
        .replaceAll(service.groupSeparator, '')
        .replaceAll(service.decimalSeparator, '.');
    final significantCharacters = cursorInput.replaceAll(RegExp('[^0-9.]'), '').length;
    final cursor = _cursorOffset(text, significantCharacters);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  int _cursorOffset(String text, int significantCharacters) {
    if (significantCharacters == 0) return text.startsWith('-') ? 1 : 0;
    var seen = 0;
    for (var index = 0; index < text.length; index++) {
      final character = text[index];
      if (RegExp('[0-9]').hasMatch(character) || character == service.decimalSeparator) {
        seen++;
        if (seen == significantCharacters) return index + 1;
      }
    }
    return text.length;
  }
}

/// A money text field that formats with locale-aware thousands separators as
/// the user types and parses its value through [NumberFormatService].
///
/// Use [controller] to read the formatted text, and [onChanged] to receive the
/// parsed numeric value (or `null` when empty/unparseable).
class DompetMoneyField extends ConsumerStatefulWidget {
  /// Creates a DompetMoneyField.
  const DompetMoneyField({
    required this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.allowNegative = false,
    this.textInputAction,
    this.enabled = true,
    super.key,
  });

  /// The controller holding the formatted text.
  final TextEditingController controller;

  /// Optional field label.
  final Widget? label;

  /// Optional field hint.
  final String? hint;

  /// Called with the parsed numeric value whenever the text changes.
  final ValueChanged<num?>? onChanged;

  /// Optional validator receiving the raw formatted text.
  final FormFieldValidator<String>? validator;

  /// When to validate.
  final AutovalidateMode? autovalidateMode;

  /// Whether negative values are permitted.
  final bool allowNegative;

  /// Keyboard action button type.
  final TextInputAction? textInputAction;

  /// Whether the field is editable.
  final bool enabled;

  @override
  ConsumerState<DompetMoneyField> createState() => _DompetMoneyFieldState();
}

class _DompetMoneyFieldState extends ConsumerState<DompetMoneyField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant DompetMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    final service = ref.read(numberFormatServiceProvider);
    onChanged(service.parse(widget.controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(numberFormatServiceProvider);

    return FTextFormField(
      control: FTextFieldControl.managed(controller: widget.controller),
      label: widget.label,
      hint: widget.hint,
      enabled: widget.enabled,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: widget.allowNegative),
      textInputAction: widget.textInputAction,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      inputFormatters: [MoneyInputFormatter(service, allowNegative: widget.allowNegative)],
      validator: widget.validator,
    );
  }
}
