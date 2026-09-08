import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:dompet/shared/widgets/dompet_donut_chart.dart';
import 'package:dompet/theme/theme.dart';

Widget wrap(Widget child) => MaterialApp(
  builder: (context, c) => FTheme(data: lightTheme, child: c!),
  home: Scaffold(
    body: Center(child: child),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DompetDonutChart', () {
    testWidgets('renders fallback empty ring when sections is empty', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DompetDonutChart(sections: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      expect(pieChart.data.sections.length, 1);
      expect(pieChart.data.sections.first.value, 1.0);
    });

    testWidgets('renders fallback empty ring when all section values are 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DompetDonutChart(
            sections: [
              DompetDonutSection(value: 0, color: Colors.blue),
              DompetDonutSection(value: 0, color: Colors.red),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      expect(pieChart.data.sections.length, 1);
    });

    testWidgets('renders single section with sectionsSpace 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DompetDonutChart(
            sections: [
              DompetDonutSection(value: 100, color: Colors.green),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      expect(pieChart.data.sections.length, 1);
      expect(pieChart.data.sectionsSpace, 0);
    });

    testWidgets('renders multiple sections with crisp divider spacing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DompetDonutChart(
            sections: [
              DompetDonutSection(value: 50, color: Colors.blue),
              DompetDonutSection(value: 30, color: Colors.orange),
              DompetDonutSection(value: 20, color: Colors.green),
            ],
            sectionsSpace: 2.5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      expect(pieChart.data.sections.length, 3);
      expect(pieChart.data.sectionsSpace, 2.5);
    });

    testWidgets('renders center child widget when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DompetDonutChart(
            sections: [
              DompetDonutSection(value: 60, color: Colors.purple),
              DompetDonutSection(value: 40, color: Colors.teal),
            ],
            center: Text('Center Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Center Content'), findsOneWidget);
    });
  });
}
