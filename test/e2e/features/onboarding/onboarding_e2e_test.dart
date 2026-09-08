import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dompet/app/app.dart';
import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/services/preferences_service.dart';
import 'package:dompet/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../robots/onboarding_robot.dart';

import 'package:dompet/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:dompet/features/settings/presentation/widgets/currency_search_list.dart';

Future<AppDatabase> pumpAppForOnboarding(WidgetTester tester) async {
  Animate.restartOnHotReload = false;

  final originalOnError = FlutterError.onError!;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    originalOnError(details);
  };

  SharedPreferences.setMockInitialValues({});
  final sharedPrefs = await SharedPreferences.getInstance();

  final memoryDb = AppDatabase(connection: NativeDatabase.memory());

  // Wait for migration and seeder to complete
  await memoryDb.customSelect('SELECT 1').get();

  // WE DO NOT SET baseCurrencyId SO IT REDIRECTS TO ONBOARDING

  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(memoryDb),
      ],
      child: const DompetApp(),
    ),
  );

  await tester.pumpAndSettle();

  return memoryDb;
}

void main() {
  testWidgets('Onboarding E2E operations', (tester) async {
    await pumpAppForOnboarding(tester);

    final robot = OnboardingRobot(tester);

    // It should start at OnboardingPage automatically
    await robot.settle();

    // Verify Onboarding Page is shown
    robot.verifyOnboardingPageShown();

    // Find and select a currency (e.g. USD)
    await robot.selectCurrency('USD');

    // Tap Continue
    await robot.tapContinue();

    // Verify it navigates to Dashboard
    robot.verifyOnboardingPageHidden();
  });
}
