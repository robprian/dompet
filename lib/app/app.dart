import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/app/router/router.dart';
import 'package:dompet/core/services/quick_actions_service.dart';
import 'package:dompet/features/backup/domain/backup_reminder_service.dart';
import 'package:dompet/features/debts/domain/debt_alert_service_provider.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/features/transactions/data/excel_export_service.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide GlobalMaterialLocalizations;

/// Root widget for Dompet CE.
class DompetApp extends HookConsumerWidget {
  const DompetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsState = ref.watch(settingsProvider);

    var themeMode = ThemeMode.system;
    switch (settingsState.settings?.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
      case 'dark':
        themeMode = ThemeMode.dark;
    }

    // Sync language state to LocaleSettings
    final lang = settingsState.settings?.language;
    useEffect(() {
      if (lang != null) {
        if (lang == 'system') {
          LocaleSettings.useDeviceLocale();
        } else {
          LocaleSettings.setLocaleRaw(lang);
        }
      }
      return null;
    }, [lang]);

    useEffect(() {
      // Run debt alerts check on startup
      ref.read(debtAlertServiceProvider).checkAlerts();

      // Check periodic backup reminder
      ref.read(backupReminderServiceProvider).checkAndNotify();

      // Clean up stale temporary exports
      ref.read(excelExportServiceProvider).cleanupOldExports();

      // Initialize quick actions
      QuickActionsService.instance.initialize();

      // Start receiving bank/QRIS notification candidates locally
      ref.read(detectionNotificationServiceProvider).start();

      return null;
    }, const []);

    return TranslationProvider(
      child: MaterialApp.router(
        title: t.app.name,
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const [
          ...FLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: themeMode,
        theme: lightTheme.toApproximateMaterialTheme(),
        darkTheme: darkTheme.toApproximateMaterialTheme(),
        builder: (context, child) => FTheme(
          data: Theme.brightnessOf(context) == Brightness.light ? lightTheme : darkTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        ),
        routerConfig: router,
      ),
    );
  }
}
