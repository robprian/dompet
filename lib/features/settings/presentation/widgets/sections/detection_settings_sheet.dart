import 'package:dompet/features/detection/presentation/controllers/detection_settings_notifier.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_switch.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet to adjust the auto-import toggle and confidence threshold.
class DetectionThresholdSheet extends ConsumerWidget {
  /// Creates the threshold sheet.
  const DetectionThresholdSheet({required this.current, super.key});

  /// Current threshold value used to highlight the active preset.
  final double current;

  /// Preset thresholds offered to the user.
  static const List<double> presets = [0.5, 0.6, 0.7, 0.8, 0.9, 0.95];

  /// Shows the sheet.
  static Future<void> show(BuildContext context, double current) {
    return showDompetSheet<void>(
      context: context,
      fitContent: true,
      builder: (context) => DetectionThresholdSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(detectionSettingsProvider);
    return settings.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (data) => _DetectionAutoImportSheet(settings: data, current: current),
    );
  }
}

/// Sheet body offering the auto-import toggle and threshold presets.
class _DetectionAutoImportSheet extends ConsumerWidget {
  const _DetectionAutoImportSheet({required this.settings, required this.current});

  final DetectionSettingsState settings;
  final double current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DompetSheet(
      title: context.t.settings.autoImport,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsMenuItem(
              title: context.t.settings.autoImport,
              subtitle: context.t.settings.autoImportDesc,
              icon: FPhosphorIcons.arrowCircleDown,
              trailing: DompetSwitch(
                value: settings.autoImportEnabled,
                onChange: (value) => ref.read(detectionSettingsProvider.notifier).setAutoImportEnabled(value: value),
              ),
            ),
            const SizedBox(height: 12),
            for (final preset in DetectionThresholdSheet.presets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FButton(
                    variant: preset == current ? FButtonVariant.primary : FButtonVariant.outline,
                    onPress: () async {
                      await ref.read(detectionSettingsProvider.notifier).setAutoImportThreshold(value: preset);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text('${(preset * 100).round()}%'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
