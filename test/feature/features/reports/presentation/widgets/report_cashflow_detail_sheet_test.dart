import 'package:dompet/features/reports/domain/services/report_analytics_service.dart';
import 'package:dompet/features/reports/presentation/widgets/report_cashflow_detail_sheet.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget _host(Widget child) {
  return ProviderScope(
    child: TranslationProvider(
      child: MaterialApp(
        builder: (context, child) => FTheme(data: lightTheme, child: child!),
        home: FScaffold(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocale(AppLocale.en);

  testWidgets('renders money in, money out, and net flow rows', (tester) async {
    await tester.pumpWidget(
      _host(
        const ReportCashflowDetailSheet(
          point: ReportTrendPoint(label: 'W1', income: 100000, expense: 40000),
        ),
      ),
    );

    expect(find.text('Money in'), findsOneWidget);
    expect(find.text('Money out'), findsOneWidget);
    expect(find.text('Net flow'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
