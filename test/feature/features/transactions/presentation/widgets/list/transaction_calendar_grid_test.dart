import 'package:dompet/core/enums.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:dompet/features/transactions/presentation/widgets/list/transaction_calendar_grid.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

TransactionModel _tx({
  required String id,
  required int amount,
  required TransactionType type,
  required DateTime date,
}) {
  return TransactionModel(
    id: id,
    accountId: 'acc1',
    type: type,
    amount: amount,
    transactionDate: date,
    createdAt: date,
    updatedAt: date,
    items: const [],
  );
}

Widget _host(Widget child) {
  return ProviderScope(
    child: FTheme(
      data: lightTheme,
      child: MaterialApp(
        home: FScaffold(child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('renders every day of the focused month', (tester) async {
    await tester.pumpWidget(
      _host(
        TransactionCalendarGrid(
          focusedDate: DateTime(2026, 2),
          transactions: const [],
          selectedDate: null,
          onSelectDate: (_) {},
        ),
      ),
    );

    expect(find.text('28'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('shows per-day totals for income and expense days', (tester) async {
    await tester.pumpWidget(
      _host(
        TransactionCalendarGrid(
          focusedDate: DateTime(2026, 2),
          transactions: [
            _tx(id: 'a', amount: 25000, type: TransactionType.expense, date: DateTime(2026, 2, 5, 10)),
            _tx(id: 'b', amount: 100000, type: TransactionType.income, date: DateTime(2026, 2, 5, 11)),
          ],
          selectedDate: DateTime(2026, 2, 5),
          onSelectDate: (_) {},
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.byType(DompetAmountText), findsNWidgets(2));
    await tester.pumpAndSettle();
  });

  testWidgets('tapping a day reports the selected date', (tester) async {
    DateTime? tapped;
    await tester.pumpWidget(
      _host(
        TransactionCalendarGrid(
          focusedDate: DateTime(2026, 2),
          transactions: const [],
          selectedDate: null,
          onSelectDate: (date) => tapped = date,
        ),
      ),
    );

    await tester.tap(find.text('14'));
    expect(tapped?.day, 14);
    expect(tapped?.month, 2);
  });
}
