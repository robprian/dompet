import 'package:dompet/core/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dompet/features/reports/presentation/screens/report_list_page.dart';
import 'package:dompet/features/settings/presentation/screens/lock_screen.dart';
import 'package:dompet/features/settings/presentation/screens/about_page.dart';
import 'package:dompet/features/settings/presentation/screens/faq_page.dart';
import 'package:dompet/features/settings/presentation/screens/markdown_page.dart';
import 'package:dompet/features/categories/presentation/widgets/views/category_list_tab.dart';
import 'package:dompet/theme/theme.dart';
import 'package:dompet/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocale(AppLocale.en);

  Widget wrapInApp(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        builder: (context, child) => TranslationProvider(
          child: FTheme(
            data: lightTheme,
            child: child!,
          ),
        ),
        home: child,
      ),
    );
  }

  group('UI Coverage Booster', () {
    testWidgets('CategoryListTab pumps', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const Scaffold(
            body: CategoryListTab(categories: [], allCategories: [], type: CategoryType.expense),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CategoryListTab), findsOneWidget);
    });

    testWidgets('AboutPage pumps', (tester) async {
      await tester.pumpWidget(wrapInApp(const AboutPage()));
      await tester.pumpAndSettle();
      expect(find.byType(AboutPage), findsOneWidget);
    });

    testWidgets('FaqPage pumps', (tester) async {
      await tester.pumpWidget(wrapInApp(const FaqPage()));
      await tester.pumpAndSettle();
      expect(find.byType(FaqPage), findsOneWidget);
    });

    testWidgets('MarkdownPage pumps', (tester) async {
      await tester.pumpWidget(wrapInApp(const MarkdownPage(title: 'T', assetPath: 'assets/docs/terms.md')));
      await tester.pumpAndSettle();
      expect(find.byType(MarkdownPage), findsOneWidget);
    });
  });
}
