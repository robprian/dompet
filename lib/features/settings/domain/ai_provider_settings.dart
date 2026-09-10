/// Settings model for AI advisor configuration.
library;

import 'package:dompet/features/advisor/domain/ai/advisor_provider_registry.dart';
import 'package:dompet/features/advisor/domain/ai/privacy_filter.dart';

/// The selected AI provider and its configuration.
class AIProviderSettings {
  const AIProviderSettings({
    required this.providerId,
    this.baseUrl,
    this.apiKey,
    this.model,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.displayName,
    this.privacyMode = PrivacyMode.strict,
    this.privacyConfig = PrivacyConfig.strict,
    this.explicitConsentGiven = false,
  });

  /// Selected provider ID (defaults to local-rules).
  final String providerId;

  /// Base URL for API-compatible providers.
  final String? baseUrl;

  /// API key (never stored in plaintext; use secure storage).
  final String? apiKey;

  /// Model name.
  final String? model;

  /// Temperature setting.
  final double temperature;

  /// Max tokens.
  final int maxTokens;

  /// Optional display name for custom providers.
  final String? displayName;

  /// Privacy mode (strict local-only or allow external AI).
  final PrivacyMode privacyMode;

  /// Detailed privacy configuration for what data to share.
  final PrivacyConfig privacyConfig;

  /// Whether the user has explicitly consented to external AI.
  final bool explicitConsentGiven;

  /// Whether this is the local (offline) provider.
  bool get isLocalProvider => providerId == 'local-rules';

  /// Display name for the selected provider.
  String get displayNameResolved {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    return ProviderConfig.displayNames[providerId] ?? providerId;
  }

  /// Provider config for the registry.
  ProviderConfig get providerConfig => ProviderConfig(
    id: providerId,
    baseUrl: baseUrl,
    apiKey: apiKey,
    model: model,
    temperature: temperature,
    maxTokens: maxTokens,
    displayName: displayName,
  );

  /// Whether external AI is enabled.
  bool get isExternalAiEnabled => !isLocalProvider && privacyMode == PrivacyMode.allowExternal && explicitConsentGiven;

  AIProviderSettings copyWith({
    String? providerId,
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    String? displayName,
    PrivacyMode? privacyMode,
    PrivacyConfig? privacyConfig,
    bool? explicitConsentGiven,
  }) {
    return AIProviderSettings(
      providerId: providerId ?? this.providerId,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      displayName: displayName ?? this.displayName,
      privacyMode: privacyMode ?? this.privacyMode,
      privacyConfig: privacyConfig ?? this.privacyConfig,
      explicitConsentGiven: explicitConsentGiven ?? this.explicitConsentGiven,
    );
  }

  /// Default settings (local-only, strict privacy).
  static const AIProviderSettings defaults = AIProviderSettings(
    providerId: 'local-rules',
  );
}

/// Privacy mode for financial data.
enum PrivacyMode { strict, allowExternal }
