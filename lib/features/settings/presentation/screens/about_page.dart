import 'package:dompet/app/router/router.dart';
import 'package:dompet/core/services/github_release_provider.dart';
import 'package:dompet/core/utils/log_exporter.dart';
import 'package:dompet/core/utils/logger.dart';
import 'package:dompet/features/settings/presentation/widgets/easter_egg_icon.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:dompet/features/settings/presentation/widgets/settings_menu_section.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// About screen displaying app version, credits, and links to source code and legal documents.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final latestRelease = ref.watch(latestGithubReleaseProvider);
    final currentVersion = const String.fromEnvironment('APP_VERSION', defaultValue: 'dev-main');

    return FScaffold(
      header: DompetHeader(
        title: t.settings.about,
        showBack: true,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(top: 48, bottom: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EasterEggIcon(),
                  const SizedBox(height: 12),
                  Text(
                    t.settings.brandName,
                    style: theme.typography.display.lg.copyWith(
                      color: theme.colors.foreground,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                       currentVersion,
                      style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.settings.aboutDescription,
                  textAlign: TextAlign.center,
                  style: theme.typography.bodyPrimary.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                 latestRelease.when(
                   data: (release) => release == null || release.tagName == currentVersion
                       ? const SizedBox.shrink()
                       : SettingsMenuSection(
                           title: 'Update available',
                           items: [
                             SettingsMenuItem(
                               title: release.tagName,
                               subtitle: 'Open the latest release on GitHub',
                               icon: FPhosphorIcons.downloadSimple,
                               onTap: () => _launchUrl(release.url.toString()),
                             ),
                           ],
                         ),
                   loading: () => const SizedBox.shrink(),
                   error: (error, stackTrace) => const SizedBox.shrink(),
                 ),
                 const SizedBox(height: 24),
                 SettingsMenuSection(
                  title: t.settings.support,
                  items: [
                    SettingsMenuItem(
                      title: t.settings.helpIssues,
                      subtitle: t.settings.reportBugsOrRequestFeatures,
                      icon: FPhosphorIcons.question,
                      onTap: () => _launchUrl('https://github.com/robprian/dompet/issues'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SettingsMenuSection(
                  title: t.settings.legal,
                  items: [
                    SettingsMenuItem(
                      title: t.settings.termsOfService,
                      subtitle: t.settings.readOurTermsAndConditions,
                      icon: FPhosphorIcons.fileText,
                      onTap: () => const SupportTermsRoute().push<void>(context),
                    ),
                    SettingsMenuItem(
                      title: t.settings.privacyPolicy,
                      subtitle: t.settings.learnHowWeHandleYourData,
                      icon: FPhosphorIcons.shieldCheck,
                      onTap: () => const SupportPrivacyRoute().push<void>(context),
                    ),
                    SettingsMenuItem(
                      title: t.settings.openSourceLicenses,
                      subtitle: t.settings.viewThirdpartySoftwareLicenses,
                      icon: FPhosphorIcons.code,
                      onTap: () => const SupportLicensesRoute().push<void>(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SettingsMenuSection(
                  title: t.settings.advanced,
                  items: [
                    SettingsMenuItem(
                      title: t.settings.exportDebugLogs,
                      subtitle: t.settings.shareErrorLogsForTroubleshooting,
                      icon: FPhosphorIcons.bug,
                      onTap: () async {
                        try {
                          await LogExporter.exportLogs();
                        } on Exception catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.settings.failedToExportLogs)),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  t.settings.copyright,
                  textAlign: TextAlign.center,
                  style: theme.typography.bodySecondary.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception catch (e, st) {
      talker.error('Could not launch $url', e, st);
    }
  }
}
