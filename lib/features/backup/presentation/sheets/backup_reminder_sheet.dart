import 'package:dompet/features/backup/domain/backup_reminder_service.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

/// Shows a bottom sheet allowing the user to configure the periodic backup reminder interval.
Future<BackupReminderInterval?> showBackupReminderSheet(
  BuildContext context, {
  required BackupReminderInterval currentInterval,
}) async {
  return showDompetSheet<BackupReminderInterval>(
    context: context,
    persistent: false,
    fitContent: true,
    builder: (context) => _BackupReminderSheet(currentInterval: currentInterval),
  );
}

class _BackupReminderSheet extends StatelessWidget {
  const _BackupReminderSheet({required this.currentInterval});

  final BackupReminderInterval currentInterval;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return DompetSheet(
      title: t.backup.reminder,
      isScrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DompetSheetActionItem(
            title: t.backup.reminderOff,
            icon: FPhosphorIcons.bellSlash,
            trailing: currentInterval == BackupReminderInterval.off
                ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(BackupReminderInterval.off),
          ),
          DompetSheetActionItem(
            title: t.backup.reminderWeekly,
            icon: FPhosphorIcons.calendarDots,
            trailing: currentInterval == BackupReminderInterval.weekly
                ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(BackupReminderInterval.weekly),
          ),
          DompetSheetActionItem(
            title: t.backup.reminderMonthly,
            icon: FPhosphorIcons.calendar,
            trailing: currentInterval == BackupReminderInterval.monthly
                ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(BackupReminderInterval.monthly),
          ),
        ],
      ),
    );
  }
}
