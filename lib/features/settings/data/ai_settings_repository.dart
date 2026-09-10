/// Service for persisting AI provider settings and API keys.
library;

import 'dart:convert';

import 'package:dompet/core/services/secure_storage_service.dart';
import 'package:dompet/features/settings/domain/ai_provider_settings.dart';

/// Repository for AI provider settings.
class AISettingsRepository {
  AISettingsRepository(this._secureStorage);

  final SecureStorageService _secureStorage;

  static const String _keyProviderId = 'ai_provider_id';
  static const String _keyConfig = 'ai_provider_config';
  static const String _keyApiKey = 'ai_api_key';
  static const String _keyPrivacyMode = 'ai_privacy_mode';
  static const String _keyConsent = 'ai_explicit_consent';

  /// Loads the current AI provider settings.
  Future<AIProviderSettings> loadSettings() async {
    final providerId = await _secureStorage.read(_keyProviderId) ?? 'local-rules';

    final configJson = await _secureStorage.read(_keyConfig);
    String? baseUrl;
    String? model;
    var temperature = 0.7;
    var maxTokens = 2048;
    String? displayName;

    if (configJson != null && configJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(configJson) as Map<String, dynamic>;
        baseUrl = decoded['baseUrl'] as String?;
        model = decoded['model'] as String?;
        temperature = (decoded['temperature'] as num?)?.toDouble() ?? 0.7;
        maxTokens = (decoded['maxTokens'] as num?)?.toInt() ?? 2048;
        displayName = decoded['displayName'] as String?;
      } on FormatException {
        // Ignore malformed config
      }
    }

    final apiKey = await _secureStorage.read(_keyApiKey);
    final privacyModeValue = await _secureStorage.read(_keyPrivacyMode);
    final consentValue = await _secureStorage.read(_keyConsent);

    final privacyMode = privacyModeValue == 'allow-external' ? PrivacyMode.allowExternal : PrivacyMode.strict;

    return AIProviderSettings(
      providerId: providerId,
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      displayName: displayName,
      privacyMode: privacyMode,
      explicitConsentGiven: consentValue == 'true',
    );
  }

  /// Persists provider selection and configuration.
  Future<void> saveSettings(AIProviderSettings settings) async {
    await _secureStorage.write(_keyProviderId, settings.providerId);

    final config = <String, dynamic>{
      if (settings.baseUrl != null) 'baseUrl': settings.baseUrl,
      if (settings.model != null) 'model': settings.model,
      'temperature': settings.temperature,
      'maxTokens': settings.maxTokens,
      if (settings.displayName != null) 'displayName': settings.displayName,
    };
    await _secureStorage.write(_keyConfig, jsonEncode(config));

    if (settings.apiKey != null && settings.apiKey!.isNotEmpty) {
      await _secureStorage.write(_keyApiKey, settings.apiKey!);
    }

    await _secureStorage.write(
      _keyPrivacyMode,
      settings.privacyMode == PrivacyMode.allowExternal ? 'allow-external' : 'strict',
    );
    await _secureStorage.write(_keyConsent, '${settings.explicitConsentGiven}');
  }

  /// Clears the API key (e.g., when switching to local-only mode).
  Future<void> clearApiKey() async {
    await _secureStorage.delete(_keyApiKey);
  }

  /// Clears all AI settings.
  Future<void> clearAll() async {
    await _secureStorage.delete(_keyProviderId);
    await _secureStorage.delete(_keyConfig);
    await _secureStorage.delete(_keyApiKey);
    await _secureStorage.delete(_keyPrivacyMode);
    await _secureStorage.delete(_keyConsent);
  }
}
