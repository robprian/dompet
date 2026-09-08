import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

enum BackupAction { backup, restore }

Future<BackupAction?> showBackupRestoreActionSheet(BuildContext context) async {
  return showDompetSheet<BackupAction>(
    context: context,
    builder: (context) => const _BackupRestoreActionSheet(),
  );
}

class _BackupRestoreActionSheet extends StatelessWidget {
  const _BackupRestoreActionSheet();

  @override
  Widget build(BuildContext context) {
    return DompetSheet(
      title: context.t.backup.title,
      isScrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DompetSheetActionItem(
            title: context.t.backup.backupAction,
            subtitle: context.t.settings.backupRestoreDesc,
            icon: FPhosphorIcons.uploadSimple,
            onTap: () => Navigator.of(context).pop(BackupAction.backup),
          ),
          DompetSheetActionItem(
            title: context.t.backup.restoreAction,
            subtitle: context.t.settings.backupRestoreDesc,
            icon: FPhosphorIcons.downloadSimple,
            onTap: () => Navigator.of(context).pop(BackupAction.restore),
          ),
        ],
      ),
    );
  }
}
