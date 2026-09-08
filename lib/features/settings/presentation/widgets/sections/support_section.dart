import 'package:dompet/app/router/router.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_section.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsMenuSection(
      title: context.t.settings.support,
      items: [
        SettingsMenuItem(
          title: context.t.settings.faq,
          subtitle: context.t.settings.faqDesc,
          icon: FPhosphorIcons.question,
          onTap: () => const SupportFaqRoute().push<void>(context),
        ),
        SettingsMenuItem(
          title: context.t.settings.about,
          subtitle: context.t.settings.aboutDesc,
          icon: FPhosphorIcons.info,
          onTap: () => const AboutRoute().push<void>(context),
        ),
      ],
    );
  }
}
