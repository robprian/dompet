import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dompet/app/app.dart'
import 'package:dompet/app/providers/repository_providers.dart'
import 'package:dompet/core/services/preferences_service.dart'
import 'package:dompet/database/database.dart'
import 'package:shared_preferences/shared_preferences.dart'
import 'package:flutter_animate/flutter_animate.dart'

/// Test-specific app that skips the startup effect
class TestDompetApp extends ConsumerWidget {
  const TestDompetApp({super.key})

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider)
    final settingsState = ref.watch(settingsProvider)

    var themeMode = ThemeMode.system
    switch (settingsState.settings?.themeMode) {
      case 'light': themeMode = ThemeMode.light
      case 'dark': themeMode = ThemeMode.dark
    }

    final lang = settingsState.settings?.language
    useEffect(() {
      if (lang != null) {
        if (lang == 'system') {
          LocaleSettings.useDeviceLocale()
        } else {
          LocaleSettings.setLocaleRaw(lang)
        }
      }
      return null
    }, [lang])

    // SKIP the startup effect that causes timer issues in tests

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
    )
  }
}

Future<AppDatabase> pumpAppForTesting(WidgetTester tester) async {
  Animate.restartOnHotReload = false

  SharedPreferences.setMockInitialValues({})
  final sharedPrefs = await SharedPreferences.getInstance()

  final memoryDb = AppDatabase(connection: NativeDatabase.memory())

  await memoryDb.customSelect('SELECT 1').get()

  final idrCurrency = await (memoryDb.select(memoryDb.currencies)..where((t) => t.code.equals('IDR'))).getSingle()
  await memoryDb.settingsDao.setSetting('baseCurrencyId', idrCurrency.id)

  tester.view.physicalSize = const Size(1080, 2400)
  tester.view.devicePixelRatio = 1.0

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(memoryDb),
      ],
      child: const TestDompetApp(),
    ),
  )

  await tester.pump(const Duration(milliseconds: 500))

  return memoryDb
}

/// Safely tears down the application and database in a test environment.
/// This prevents hanging (deadlock) where Drift's `db.close()` waits for
/// active streams to close, which in turn require `FakeAsync` timers to run.
Future<void> tearDownAppForTesting(WidgetTester tester, AppDatabase db) async {
  // Unmount the application to cancel all Riverpod stream listeners
  await tester.pumpWidget(Container())
  // Process any pending FakeAsync timers (like Drift's stream debouncers)
  await tester.pumpAndSettle()
  // Now it's safe to close the database without hanging
  await db.close()
}