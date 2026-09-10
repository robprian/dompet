import 'package:dompet/features/advisor/domain/ai/advisor_provider_registry.dart';
import 'package:dompet/features/settings/domain/ai_provider_settings.dart';
import 'package:dompet/features/settings/presentation/controllers/ai_settings_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet for configuring the AI advisor provider.
class AISettingsSheet extends HookConsumerWidget {
  const AISettingsSheet({super.key});

  /// Shows the AI settings sheet.
  static Future<void> show(BuildContext context) {
    return showDompetSheet<void>(
      context: context,
      builder: (context) => const AISettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(aiSettingsProvider);
    final theme = context.theme;
    final notifier = ref.read(aiSettingsProvider.notifier);
    final baseUrlController = useTextEditingController(text: settings.baseUrl ?? '');
    final modelController = useTextEditingController(text: settings.model ?? '');
    final apiKeyController = useTextEditingController(text: settings.apiKey ?? '');
    final displayNameController = useTextEditingController(text: settings.displayName ?? '');
    final providerId = useState(settings.providerId);

    void saveConfig() {
      notifier.updateConfig(
        baseUrl: baseUrlController.text.trim().isEmpty ? null : baseUrlController.text.trim(),
        model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
        apiKey: apiKeyController.text.trim().isEmpty ? null : apiKeyController.text.trim(),
        displayName: displayNameController.text.trim().isEmpty ? null : displayNameController.text.trim(),
      );
    }

    return DompetSheet(
      title: context.t.settings.aiAdvisor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Provider selection
              Text(context.t.settings.aiProvider, style: theme.typography.labelSection),
              const SizedBox(height: 8),
              for (final providerIdValue in AdvisorProviderRegistry.providerIds) ...[
                FButton(
                  variant: providerId.value == providerIdValue ? FButtonVariant.primary : FButtonVariant.outline,
                  onPress: () async {
                    providerId.value = providerIdValue;
                    await notifier.selectProvider(providerIdValue);
                    if (providerIdValue != 'local-rules' && context.mounted) {
                      await _showPrivacyConsent(context, ref, notifier);
                    }
                  },
                  child: Text(ProviderConfig.displayNames[providerIdValue] ?? providerIdValue),
                ),
                const SizedBox(height: 8),
              ],

              if (!settings.isLocalProvider) ...[
                const SizedBox(height: 16),
                Text(context.t.settings.aiProviderConfig, style: theme.typography.labelSection),
                const SizedBox(height: 8),
                if (settings.providerId == 'custom') ...[
                  FTextField(
                    hint: context.t.settings.aiDisplayName,
                    control: FTextFieldControl.managed(controller: displayNameController),
                  ),
                  const SizedBox(height: 8),
                ],
                FTextField(
                  hint: context.t.settings.aiBaseUrl,
                  control: FTextFieldControl.managed(controller: baseUrlController),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
                FTextField(
                  hint: context.t.settings.aiModel,
                  control: FTextFieldControl.managed(controller: modelController),
                ),
                const SizedBox(height: 8),
                FTextField(
                  hint: context.t.settings.aiApiKey,
                  control: FTextFieldControl.managed(controller: apiKeyController),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                FButton(
                  onPress: saveConfig,
                  child: Text(context.t.common.save),
                ),
              ],

              const SizedBox(height: 16),
              // Privacy mode
              Text(context.t.settings.aiPrivacyMode, style: theme.typography.labelSection),
              const SizedBox(height: 8),
              FButton(
                variant: settings.privacyMode == PrivacyMode.strict ? FButtonVariant.primary : FButtonVariant.outline,
                onPress: () => notifier.setPrivacyMode(PrivacyMode.strict),
                child: Text(context.t.settings.aiPrivacyStrict),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: settings.privacyMode == PrivacyMode.allowExternal
                    ? FButtonVariant.primary
                    : FButtonVariant.outline,
                onPress: () => notifier.setPrivacyMode(PrivacyMode.allowExternal),
                child: Text(context.t.settings.aiPrivacyExternal),
              ),

              const SizedBox(height: 16),
              // Reset to local
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () async {
                  await notifier.resetToLocal();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(context.t.settings.aiResetToLocal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPrivacyConsent(
    BuildContext context,
    WidgetRef ref,
    AISettingsNotifier notifier,
  ) async {
    if (!context.mounted) return;
    final confirmed = await showDompetSheet<bool>(
      context: context,
      fitContent: true,
      builder: (context) => DompetSheet(
        title: context.t.settings.aiPrivacyNotice,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.t.settings.aiPrivacyWarning, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FButton(
                onPress: () async {
                  await notifier.grantConsent();
                  if (context.mounted) Navigator.of(context).pop(true);
                },
                child: Text(context.t.settings.aiContinue),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(context.t.common.cancel),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) {
      await notifier.selectProvider('local-rules');
    }
  }
}
