import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

Future<String?> showLanguagePickerSheet(BuildContext context, String currentLanguage) {
  return showDompetSheet<String>(
    context: context,
    builder: (context) => DompetSheet(
      title: context.t.settings.selectLanguage,
      isScrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DompetSheetActionItem(
            title: context.t.settings.english,
            icon: FPhosphorIcons.translate,
            trailing: currentLanguage == 'en' ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary) : null,
            onTap: () => Navigator.of(context).pop('en'),
          ),
          DompetSheetActionItem(
            title: context.t.settings.indonesia,
            icon: FPhosphorIcons.translate,
            trailing: currentLanguage == 'id' ? Icon(FPhosphorIcons.check, color: context.theme.colors.primary) : null,
            onTap: () => Navigator.of(context).pop('id'),
          ),
        ],
      ),
    ),
  );
}
