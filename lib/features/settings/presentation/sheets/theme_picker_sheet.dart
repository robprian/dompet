import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

Future<String?> showThemePickerSheet(BuildContext context, String currentTheme) {
  return showDompetSheet<String>(
    context: context,
    builder: (context) => DompetSheet(
      title: context.t.settings.selectTheme,
      isScrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DompetSheetActionItem(
            title: context.t.settings.system,
            icon: FPhosphorIcons.devices,
            trailing: currentTheme == 'system' ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary) : null,
            onTap: () => Navigator.of(context).pop('system'),
          ),
          DompetSheetActionItem(
            title: context.t.settings.themeLight,
            icon: FPhosphorIcons.sun,
            trailing: currentTheme == 'light' ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary) : null,
            onTap: () => Navigator.of(context).pop('light'),
          ),
          DompetSheetActionItem(
            title: context.t.settings.themeDark,
            icon: FPhosphorIcons.moon,
            trailing: currentTheme == 'dark' ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary) : null,
            onTap: () => Navigator.of(context).pop('dark'),
          ),
        ],
      ),
    ),
  );
}
