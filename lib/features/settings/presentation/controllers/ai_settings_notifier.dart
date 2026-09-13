import 'package:dompet/core/services/secure_storage_service.dart';
import 'package:dompet/features/advisor/domain/ai/advisor_provider_registry.dart';
import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:dompet/features/advisor/domain/ai/local_rule_provider.dart';
import 'package:dompet/features/settings/data/ai_settings_repository.dart';
import 'package:dompet/features/settings/domain/ai_provider_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [AISettingsRepository].
final aiSettingsRepositoryProvider = Provider<AISettingsRepository>((ref) {
  return AISettingsRepository(ref.watch(secureStorageProvider));
});

/// Notifier managing AI provider settings.
class AISettingsNotifier extends Notifier<AIProviderSettings> {
  @override
  AIProviderSettings build() {
    _load();
    return AIProviderSettings.defaults;
  }

  Future<void> _load() async {
    final settings = await ref.read(aiSettingsRepositoryProvider).loadSettings();
    if (!ref.mounted) return;
    state = settings;
  }

  /// Selects an AI provider.
  Future<void> selectProvider(String providerId) async {
    final current = state;
    final updated = current.copyWith(
      providerId: providerId,
      explicitConsentGiven: !(providerId == 'local-rules') && current.explicitConsentGiven,
    );
    await ref.read(aiSettingsRepositoryProvider).saveSettings(updated);
    state = updated;
  }

  /// Updates provider configuration (base URL, model, etc.).
  Future<void> updateConfig({
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    String? displayName,
    String? apiKey,
  }) async {
    final current = state;
    final updated = current.copyWith(
      baseUrl: baseUrl ?? current.baseUrl,
      model: model ?? current.model,
      temperature: temperature ?? current.temperature,
      maxTokens: maxTokens ?? current.maxTokens,
      displayName: displayName ?? current.displayName,
      apiKey: apiKey ?? current.apiKey,
    );
    await ref.read(aiSettingsRepositoryProvider).saveSettings(updated);
    state = updated;
  }

  /// Sets the privacy mode (strict local-only or allow external AI).
  Future<void> setPrivacyMode(PrivacyMode mode) async {
    final current = state;
    final updated = current.copyWith(privacyMode: mode);
    if (mode == PrivacyMode.strict) {
      await ref.read(aiSettingsRepositoryProvider).saveSettings(updated.copyWith(providerId: 'local-rules'));
      state = updated.copyWith(providerId: 'local-rules');
    } else {
      await ref.read(aiSettingsRepositoryProvider).saveSettings(updated);
      state = updated;
    }
  }

  /// Grants explicit consent for external AI use.
  Future<void> grantConsent() async {
    final updated = state.copyWith(explicitConsentGiven: true);
    await ref.read(aiSettingsRepositoryProvider).saveSettings(updated);
    state = updated;
  }

  /// Tests connectivity for a draft provider config without persisting it.
  /// Returns true when the provider answers its `/models` probe in time.
  /// [createProvider] is injectable so QA tests can supply a fake probe.
  Future<bool> testConnection({
    String? baseUrl,
    String? model,
    String? apiKey,
    String? providerId,
    AdvisorProvider Function(ProviderConfig config)? createProvider,
  }) async {
    final current = state;
    final id = providerId ?? current.providerId;
    if (id == 'local-rules') return true;
    final config = ProviderConfig(
      id: id,
      baseUrl:
          (baseUrl?.trim().isNotEmpty ?? false ? baseUrl!.trim() : null) ??
          current.baseUrl ??
          ProviderConfig.defaultBaseUrls[id],
      apiKey: (apiKey?.trim().isNotEmpty ?? false ? apiKey!.trim() : null) ?? current.apiKey ?? '',
      model:
          (model?.trim().isNotEmpty ?? false ? model!.trim() : null) ??
          current.model ??
          ProviderConfig.defaultModels[id],
      temperature: current.temperature,
      maxTokens: current.maxTokens,
      displayName: current.displayName,
    );
    final provider = (createProvider ?? const AdvisorProviderRegistry().createProvider)(config);
    return provider.isAvailable();
  }

  /// Resets to local-only mode.
  Future<void> resetToLocal() async {
    await ref.read(aiSettingsRepositoryProvider).clearApiKey();
    const updated = AIProviderSettings.defaults;
    await ref.read(aiSettingsRepositoryProvider).saveSettings(updated);
    state = updated;
  }
}

/// Provider for [AISettingsNotifier].
final aiSettingsProvider = NotifierProvider<AISettingsNotifier, AIProviderSettings>(AISettingsNotifier.new);

/// Provider for the active [AdvisorProvider] based on settings.
final activeAdvisorProviderProvider = Provider<AdvisorProvider>((ref) {
  final settings = ref.watch(aiSettingsProvider);
  if (settings.isLocalProvider) {
    return LocalRuleProvider();
  }

  return const AdvisorProviderRegistry().createProvider(settings.providerConfig);
});
