/// Registry of available AI advisor providers.
library;

import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:dompet/features/advisor/domain/ai/local_rule_provider.dart';
import 'package:dompet/features/advisor/domain/ai/openai_compatible_provider.dart';

/// Registry that maps provider IDs to their constructors.
class AdvisorProviderRegistry {
  const AdvisorProviderRegistry();

  /// All built-in provider IDs.
  static const List<String> providerIds = [
    'local-rules',
    'openai',
    'anthropic',
    'gemini',
    'openai-compatible',
    'custom',
  ];

  /// Creates a local rule provider.
  static LocalRuleProvider createLocalRuleProvider() => LocalRuleProvider();

  /// Creates an OpenAI-compatible provider with the given config.
  static OpenAICompatibleProvider createOpenAICompatibleProvider({
    required String baseUrl,
    required String apiKey,
    required String model,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) {
    return OpenAICompatibleProvider(
      config: OpenAICompatibleConfig(
        baseUrl: baseUrl,
        apiKey: apiKey,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
      ),
    );
  }

  /// Creates the default local provider.
  AdvisorProvider createProvider(ProviderConfig config) {
    switch (config.id) {
      case 'local-rules':
        return createLocalRuleProvider();
      case 'openai-compatible':
      case 'openai':
      case 'anthropic':
      case 'gemini':
      case 'custom':
        return createOpenAICompatibleProvider(
          baseUrl: config.baseUrl ?? ProviderConfig.defaultBaseUrls[config.id] ?? 'https://api.openai.com/v1',
          apiKey: config.apiKey ?? '',
          model: config.model ?? ProviderConfig.defaultModels[config.id] ?? 'gpt-4o-mini',
          temperature: config.temperature ?? 0.7,
          maxTokens: config.maxTokens ?? 2048,
        );
      default:
        return createLocalRuleProvider();
    }
  }
}

/// Configuration for a provider.
class ProviderConfig {
  const ProviderConfig({
    required this.id,
    this.baseUrl,
    this.apiKey,
    this.model,
    this.temperature,
    this.maxTokens,
    this.displayName,
  });

  /// Provider ID.
  final String id;

  /// Base URL for API-compatible providers.
  final String? baseUrl;

  /// API key (stored securely, never in plaintext).
  final String? apiKey;

  /// Model name.
  final String? model;

  /// Temperature setting.
  final double? temperature;

  /// Max tokens.
  final int? maxTokens;

  /// Optional display name for custom providers.
  final String? displayName;

  /// Default provider IDs and their display names.
  static const Map<String, String> displayNames = {
    'local-rules': 'Local Rules (Offline)',
    'openai': 'OpenAI',
    'anthropic': 'Anthropic (Claude)',
    'gemini': 'Google Gemini',
    'openai-compatible': 'OpenAI Compatible',
    'custom': 'Custom',
  };

  /// Default base URLs for known providers.
  static const Map<String, String> defaultBaseUrls = {
    'openai': 'https://api.openai.com/v1',
    'anthropic': 'https://api.anthropic.com/v1',
    'gemini': 'https://generativelanguage.googleapis.com/v1beta',
  };

  /// Default models for known providers.
  static const Map<String, String> defaultModels = {
    'openai': 'gpt-4o-mini',
    'anthropic': 'claude-3-5-sonnet-latest',
    'gemini': 'gemini-1.5-flash',
  };
}
