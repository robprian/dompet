import 'package:intl/intl.dart';

/// Centralised, locale-aware number and currency formatting.
///
/// The app stores raw amounts as [num] and exposes a user preference
/// (the `numberFormat` field in settings) that is either the special value
/// `system` (device locale) or an explicit locale id such as `id_ID`,
/// `en_US`, `fr_FR`.
///
/// All UI formatting must go through this service so thousands/decimal
/// separators stay consistent between inputs, calculators, and displays.
class NumberFormatService {
  /// Creates a service bound to a [numberFormat] preference value.
  const NumberFormatService(this.numberFormat);

  /// Sentinel meaning "follow the device locale".
  static const String systemLocale = 'system';

  /// The raw preference value (`system` or a locale id).
  final String numberFormat;

  /// Resolved locale id for `intl`, or `null` to defer to the device locale.
  String? get locale => numberFormat == systemLocale ? null : numberFormat;

  NumberFormat _integer() => NumberFormat('#,##0', locale);

  NumberFormat _decimal() => NumberFormat('#,##0.############', locale);

  NumberFormat _currency(String symbol, int precision) => NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: precision,
  );

  /// The thousands separator for the active locale (e.g. `.` for `id_ID`).
  String get groupSeparator => _integer().symbols.GROUP_SEP;

  /// The decimal separator for the active locale (e.g. `,` for `id_ID`).
  String get decimalSeparator => _integer().symbols.DECIMAL_SEP;

  /// Formats a whole number with grouping, e.g. `1000000` -> `1.000.000`.
  String formatInt(int value) => _integer().format(value);

  /// Formats a [num], dropping trailing zeros for whole values.
  String format(num value) {
    if (value is int || value == value.roundToDouble()) {
      return _integer().format(value);
    }
    return _decimal().format(value);
  }

  /// Formats a raw numeric string (calculator expression fragment) with
  /// grouping while preserving the fractional part the user typed.
  ///
  /// Unlike a naive `split('.')`, this delegates grouping to `intl` and only
  /// re-appends the fraction using the locale decimal separator, so `id_ID`
  /// renders `1.234,5` rather than colliding with its own group separator.
  String formatNumericString(String raw) {
    if (raw.isEmpty) return '0';
    final dot = raw.indexOf('.');
    if (dot < 0) {
      final parsed = int.tryParse(raw);
      return parsed == null ? raw : formatInt(parsed);
    }
    final intPart = raw.substring(0, dot);
    final fracPart = raw.substring(dot + 1);
    final parsed = int.tryParse(intPart.isEmpty ? '0' : intPart);
    final formattedInt = parsed == null ? intPart : formatInt(parsed);
    return '$formattedInt$decimalSeparator$fracPart';
  }

  /// Formats a currency amount with the given [symbol] and [precision].
  String formatCurrency(num value, {required String symbol, required int precision}) {    final cleanSymbol = symbol.trim();
    final effectiveSymbol = cleanSymbol.isEmpty ? '' : '$cleanSymbol ';
    return _currency(effectiveSymbol, precision).format(value);
  }

  /// Parses a user-entered formatted number string into a [num] or `null`.
  String normalizeGrouping(String raw) => formatNumericString(raw);
}
