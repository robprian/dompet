import 'dart:convert';

import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/settings/domain/ai_provider_settings.dart';
import 'package:http/http.dart' as http;

/// Optional AI helper that suggests a category for a transaction from its note.
///
/// This is strictly opt-in: it is only invoked when the user has configured an
/// external AI provider (and consented to external use). In the default
/// local-only mode it resolves to `null` and never touches the network, which
/// keeps the offline-first guarantee intact.
class TransactionAiAssistService {
  /// Creates the service from the current [settings].
  const TransactionAiAssistService({
    required this.settings,
    http.Client? httpClient,
  }) : _client = httpClient;

  /// Active AI provider settings.
  final AIProviderSettings settings;

  final http.Client? _client;

  /// Whether AI assistance can be used given the current settings.
  bool get isEnabled => settings.isExternalAiEnabled;

  /// Suggests a category id from [categories] for the given [note], or `null`.
  ///
  /// Returns `null` when AI is disabled, the note is empty, the request fails,
  /// or the model does not pick one of the provided categories.
  Future<String?> suggestCategoryId({
    required String note,
    required List<CategoryModel> categories,
  }) async {
    if (!isEnabled || note.trim().isEmpty || categories.length < 2) return null;

    final baseUrl = settings.baseUrl?.trim();
    final apiKey = settings.apiKey;
    final model = settings.model;
    if (baseUrl == null || baseUrl.isEmpty || apiKey == null || model == null || model.isEmpty) {
      return null;
    }

    final allowed = {for (final c in categories) c.id: c.name};
    final client = _client ?? http.Client();
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/chat/completions',
    );

    final candidates = allowed.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    final body = jsonEncode({
      'model': model,
      'temperature': 0,
      'max_tokens': 32,
      'messages': [
        {
          'role': 'system',
          'content': 'You categorise personal finance transactions. Reply with ONLY the id of the best matching category, or NONE. No other text.',
        },
        {
          'role': 'user',
          'content': 'Transaction note: "$note"\n\nCategories:\n$candidates',
        },
      ],
    });

    try {
      final response = await client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final content = (data['choices']?[0]?['message']?['content'] as String?)?.trim();
      if (content == null || content.isEmpty || content.toUpperCase() == 'NONE') return null;
      return allowed.containsKey(content) ? content : null;
    } on Object {
      return null;
    } finally {
      if (_client == null) client.close();
    }
  }
}
