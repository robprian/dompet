import 'package:dompet/core/utils/number_format_service.dart';
import 'package:flutter/material.dart';

/// String manipulation and color/number parsing extensions.
extension StringExtension on String {
  /// Parses a hex color string (e.g. "#FF0000" or "FF0000") into a [Color].
  Color toColor([Color defaultColor = const Color(0xFFCCCCCC)]) {
    try {
      final hexCodeClean = replaceAll('#', '');
      return Color(int.parse('FF$hexCodeClean', radix: 16));
    } on Exception catch (_) {
      return defaultColor;
    }
  }

  /// Formats a raw number string (e.g. "50000.5") into a localized string
  /// (e.g. "50,000.5" or "50.000,5") using the active number-format locale.
  String formatAsNumber({String localeFormat = NumberFormatService.systemLocale}) {
    return NumberFormatService(localeFormat).formatNumericString(this);
  }

  /// Evaluates and formats a raw math expression string, e.g.
  /// "5000+10.5" -> "5,000 + 10,5".
  String formatMathExpression({String localeFormat = NumberFormatService.systemLocale}) {
    final service = NumberFormatService(localeFormat);
    final regex = RegExp(r'(\d+(?:\.\d*)?)|([+\-*/])');
    final matches = regex.allMatches(this);

    final buffer = StringBuffer();
    for (final match in matches) {
      final text = match.group(0)!;
      if (text == '+' || text == '-' || text == '*' || text == '/') {
        if (text == '*') {
          buffer.write(' × ');
        } else if (text == '/') {
          buffer.write(' ÷ ');
        } else {
          buffer.write(' $text ');
        }
      } else {
        buffer.write(service.formatNumericString(text));
      }
    }
    return buffer.toString().trim();
  }
}
