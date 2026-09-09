import 'package:dompet/features/detection/presentation/controllers/detection_settings_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet to adjust the auto-import confidence threshold.
class DetectionThresholdSheet extends ConsumerWidget {
  /// Creates the threshold sheet.
  const DetectionThresholdSheet({required this.current, super.key});

  /// Current threshold value.
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
    return DompetSheet(
      title: context.t.settings.detectionThreshold,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final preset in presets)
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
