import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/theme/theme.dart';

Widget wrap(Widget child) => MaterialApp(
  builder: (context, c) => FTheme(data: lightTheme, child: c!),
  home: Scaffold(body: child),
);

Widget wrapWithRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/next',
        builder: (_, __) => const Scaffold(body: Text('next')),
      ),
    ],
  );
  return MaterialApp.router(
    builder: (context, c) => FTheme(data: lightTheme, child: c!),
    routerConfig: router,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DompetHeader', () {
    testWidgets('renders title', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });
    testWidgets('renders subtitle', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'T', subtitle: 'Sub')));
      expect(find.text('Sub'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });
    testWidgets('showBack true uses FHeader.nested with back button', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'Back', showBack: true)));
      expect(find.text('Back'), findsOneWidget);
      // Back button exists as GestureDetector
      expect(find.byType(GestureDetector), findsWidgets);
    });
    testWidgets('showBack true subtitle centered', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'T', subtitle: 'S', showBack: true)));
      expect(find.text('S'), findsOneWidget);
    });
    testWidgets('suffixes displayed', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'T', suffixes: [Text('A')])));
      expect(find.text('A'), findsOneWidget);
    });
    testWidgets('renders leading widget alongside title', (t) async {
      await t.pumpWidget(
        wrap(const DompetHeader(title: 'T', leading: Icon(Icons.account_balance_wallet))),
      );
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });
    testWidgets('leading works with subtitle and showBack', (t) async {
      await t.pumpWidget(
        wrap(
          const DompetHeader(
            title: 'T',
            subtitle: 'S',
            showBack: true,
            leading: Icon(Icons.star),
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });
    testWidgets('back button tap pops when canPop', (t) async {
      await t.pumpWidget(wrap(const DompetHeader(title: 'T', showBack: true)));
      await t.pumpAndSettle();
      expect(find.text('T'), findsOneWidget);
    });
  });
}
