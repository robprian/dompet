import 'package:dompet/features/detection/domain/parsers/notification_text_utils.dart';

/// Result from the deterministic local category classifier.
class CategoryInference {
  /// Creates a category inference.
  const CategoryInference({required this.label, required this.confidence});

  /// Suggested category label; UI/repository maps this to a local category ID.
  final String label;

  /// 0.0-1.0 confidence.
  final double confidence;
}

/// Learns and applies offline merchant/category rules.
class CategoryInferenceEngine {
  /// Creates an engine with Indonesian merchant keyword rules.
  CategoryInferenceEngine({Map<String, String>? rules}) : _rules = {...defaultRules, ...?rules};

  /// Default locally-known merchant mappings.
  static const Map<String, String> defaultRules = {
    'pln': 'Utilities',
    'token listrik': 'Utilities',
    'telkomsel': 'Mobile / Internet',
    'indosat': 'Mobile / Internet',
    'xl': 'Mobile / Internet',
    'by.u': 'Mobile / Internet',
    'netflix': 'Subscription / Entertainment',
    'spotify': 'Subscription / Entertainment',
    'disney': 'Subscription / Entertainment',
    'tokopedia': 'Shopping',
    'shopee': 'Shopping',
    'lazada': 'Shopping',
    'gofood': 'Food & Dining',
    'grabfood': 'Food & Dining',
    'kopi kenangan': 'Food & Dining',
    'starbucks': 'Food & Dining',
    'kopi': 'Food & Dining',
    'indomaret': 'Shopping',
    'alfamart': 'Shopping',
    'rumah sakit': 'Health',
    'apotek': 'Health',
    'grab': 'Transport',
    'gojek': 'Transport',
    'pertamina': 'Transport',
  };

  final Map<String, String> _rules;

  /// Adds or replaces a learned merchant rule locally.
  void learn({required String merchant, required String category}) {
    final normalized = normalizeText(merchant);
    if (normalized.isNotEmpty) _rules[normalized] = category;
  }

  /// Infers a category from merchant/name text.
  CategoryInference? infer(String? merchant) {
    if (merchant == null || merchant.trim().isEmpty) return null;
    final normalized = normalizeText(merchant);
    String? bestKey;
    for (final key in _rules.keys) {
      if (!normalized.contains(key)) continue;
      if (bestKey == null || key.length > bestKey.length) bestKey = key;
    }
    if (bestKey == null) return null;
    final confidence = bestKey.length >= 8 ? 0.95 : 0.82;
    return CategoryInference(label: _rules[bestKey]!, confidence: confidence);
  }
}
