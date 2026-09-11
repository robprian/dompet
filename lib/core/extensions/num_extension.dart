import 'package:dompet/core/utils/number_format_service.dart';

/// Formatting helpers for numeric values (integers and doubles).
extension NumExtension on num {
  /// Converts the number to compact abbreviated string (e.g. 1.2K, 3.4M, 5.0B).
  String toCompactFormat() {
    if (this >= 1000000000) return '${(this / 1000000000).toStringAsFixed(1)}B';
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(0);
  }

  /// Formats the number as currency with symbol, decimals, and optional obfuscation.
  String toCurrencyFormat({
    required String symbol,
    required int precision,
    String? locale,
    bool isVisible = true,
  }) {
    final cleanSymbol = symbol.trim();
    final effectiveSymbol = cleanSymbol.isEmpty ? '' : '$cleanSymbol ';

    if (!isVisible) return '$effectiveSymbol••••••';

    return NumberFormatService(locale ?? NumberFormatService.systemLocale).formatCurrency(
      this,
      symbol: cleanSymbol,
      precision: precision,
    );
  }
}
