import 'package:dompet/features/settings/domain/ai_provider_settings.dart';
import 'package:dompet/features/settings/presentation/controllers/ai_settings_notifier.dart';
import 'package:dompet/features/settings/presentation/widgets/sections/ai_settings_sheet.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_section.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings entries for the AI Advisor configuration.
class AISection extends ConsumerWidget {
  const AISection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSettings = ref.watch(aiSettingsProvider);

    final providerName = aiSettings.displayNameResolved;
    final status = aiSettings.isLocalProvider
        ? context.t.settings.aiLocalActive
        : (aiSettings.isExternalAiEnabled ? context.t.settings.aiExternalActive : context.t.settings.aiConfigureNeeded);

    return SettingsMenuSection(
      title: context.t.settings.aiAdvisor,
      items: [
        SettingsMenuItem(
          title: context.t.settings.aiProvider,
          subtitle: providerName,
          icon: FPhosphorIcons.robot,
          onTap: () => AISettingsSheet.show(context),
        ),
        SettingsMenuItem(
          title: context.t.settings.aiStatus,
          subtitle: status,
          icon: FPhosphorIcons.heartbeat,
          onTap: () => AISettingsSheet.show(context),
        ),
        SettingsMenuItem(
          title: context.t.settings.aiPrivacyMode,
          subtitle: aiSettings.privacyMode == PrivacyMode.strict
              ? context.t.settings.aiPrivacyStrict
              : context.t.settings.aiPrivacyExternal,
          icon: FPhosphorIcons.shieldCheck,
          onTap: () => AISettingsSheet.show(context),
        ),
      ],
    );
  }
}
