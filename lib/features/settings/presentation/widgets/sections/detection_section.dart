import 'package:dompet/app/router/router.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_settings_notifier.dart';
import 'package:dompet/features/settings/presentation/widgets/sections/detection_settings_sheet.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_section.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_switch.dart';
import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings entries for the Dompet Advisor and local transaction detection.
class DetectionSection extends ConsumerWidget {
  /// Creates the detection settings section.
  const DetectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(detectionSettingsProvider);
    final pendingCountAsync = ref.watch(pendingDetectionCountProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (settings) {
        return SettingsMenuSection(
          title: context.t.settings.advisor,
          items: [
            SettingsMenuItem(
              title: context.t.settings.advisorTitle,
              subtitle: context.t.settings.advisorDesc,
              icon: FPhosphorIcons.lightbulb,
              onTap: () => const AdvisorRoute().push<void>(context),
            ),
            SettingsMenuItem(
              title: context.t.settings.reviewQueue,
              subtitle: '${pendingCountAsync.value ?? 0} · ${context.t.settings.reviewQueueDesc}',
              icon: FPhosphorIcons.notification,
              onTap: () => const DetectionReviewRoute().push<void>(context),
            ),
            SettingsMenuItem(
              title: context.t.settings.notificationAccess,
              subtitle: settings.accessEnabled ? context.t.settings.accessGranted : context.t.settings.accessDenied,
              icon: FPhosphorIcons.bellSimple,
              onTap: () => ref.read(detectionSettingsProvider.notifier).requestNotificationAccess(),
            ),
            SettingsMenuItem(
              title: context.t.settings.enableDetection,
              subtitle: context.t.settings.enableDetectionDesc,
              icon: FPhosphorIcons.eye,
              trailing: DompetSwitch(
                value: settings.enabled,
                onChange: (value) => ref.read(detectionSettingsProvider.notifier).setEnabled(value: value),
              ),
            ),
            SettingsMenuItem(
              title: context.t.settings.autoImport,
              subtitle: context.t.settings.autoImportDesc,
              icon: FPhosphorIcons.arrowCircleDown,
              trailing: DompetSwitch(
                value: settings.autoImportEnabled,
                onChange: (value) => ref.read(detectionSettingsProvider.notifier).setAutoImportEnabled(value: value),
              ),
            ),
            SettingsMenuItem(
              title: context.t.settings.detectionThreshold,
              subtitle: '${(settings.autoImportThreshold * 100).round()}%',
              icon: FPhosphorIcons.gauge,
              onTap: () => DetectionThresholdSheet.show(context, settings.autoImportThreshold),
            ),
            SettingsMenuItem(
              title: context.t.settings.salaryDetected,
              subtitle: context.t.settings.salaryDetectionDesc,
              icon: FPhosphorIcons.bank,
              trailing: DompetSwitch(
                value: settings.salaryDetectionEnabled,
                onChange: (value) => ref.read(detectionSettingsProvider.notifier).setSalaryDetectionEnabled(value: value),
              ),
            ),
          ],
        );
      },
    );
  }
}
