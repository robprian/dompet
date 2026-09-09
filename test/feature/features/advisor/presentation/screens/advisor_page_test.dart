import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/advisor/presentation/controllers/advisor_notifier.dart';
import 'package:dompet/features/advisor/presentation/screens/advisor_page.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

Widget buildTestableWidget(Widget child, List<AdvisorRecommendationModel> items) {
  return TranslationProvider(
    child: ProviderScope(
      overrides: [
        advisorProvider.overrideWithValue(AdvisorState(recommendations: items, isLoading: false)),
      ],
      child: MaterialApp(
        builder: (context, child) => FTheme(data: lightTheme, child: child!),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocale(AppLocale.en);

  testWidgets('AdvisorPage shows recommendations with allocation breakdown', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const AdvisorPage(),
        const [
          AdvisorRecommendationModel(
            id: 'r1',
            type: AdvisorRecommendationType.salaryAllocation,
            severity: AdvisorSeverity.info,
            amount: 10000000,
            isSalaryRelated: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Income allocation'), findsOneWidget);
    expect(find.text('Needs'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('5000000'), findsOneWidget);
  });

  testWidgets('AdvisorPage shows empty state without recommendations', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AdvisorPage(), const []));
    await tester.pumpAndSettle();

    expect(find.text('No advice yet. Add transactions to see insights.'), findsOneWidget);
  });

  testWidgets('AdvisorPage shows budget warnings', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const AdvisorPage(),
        const [
          AdvisorRecommendationModel(
            id: 'r2',
            type: AdvisorRecommendationType.budget,
            severity: AdvisorSeverity.warning,
            amount: 200000,
            ratio: 1.2,
            relatedName: 'Makan',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budget exceeded'), findsOneWidget);
  });
}
