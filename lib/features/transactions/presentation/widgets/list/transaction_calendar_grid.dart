import 'package:dompet/core/enums.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Full-month calendar grid showing per-day income (green) and expense (red)
/// totals. Reuses the grouped daily totals already produced by the
/// transaction list so no extra query is required.
class TransactionCalendarGrid extends StatelessWidget {
  const TransactionCalendarGrid({
    required this.focusedDate,
    required this.transactions,
    required this.selectedDate,
    required this.onSelectDate,
    super.key,
  });

  final DateTime focusedDate;
  final List<TransactionModel> transactions;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final monthStart = DateTime(focusedDate.year, focusedDate.month);
    final firstWeekday = monthStart.weekday;
    final daysInMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;

    final totals = <int, ({int income, int expense})>{};
    for (final tx in transactions) {
      final d = tx.transactionDate.toLocal();
      if (d.year != focusedDate.year || d.month != focusedDate.month) continue;
      final entry = totals[d.day] ?? (income: 0, expense: 0);
      totals[d.day] = switch (tx.type) {
        TransactionType.income => (income: entry.income + tx.amount, expense: entry.expense),
        TransactionType.expense => (income: entry.income, expense: entry.expense + tx.amount),
        TransactionType.transfer => entry,
      };
    }

    const weekdayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.72,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();
            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(focusedDate.year, focusedDate.month, day);
            final entry = totals[day];
            final isSelected =
                selectedDate != null &&
                selectedDate!.year == date.year &&
                selectedDate!.month == date.month &&
                selectedDate!.day == date.day;
            final isToday = _isToday(date);
            return GestureDetector(
              onTap: () => onSelectDate(date),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colors.primary.withValues(alpha: 0.12) : theme.colors.card,
                  borderRadius: theme.style.borderRadius.sm,
                  border: Border.all(
                    color: isSelected
                        ? theme.colors.primary
                        : isToday
                        ? theme.colors.primary.withValues(alpha: 0.5)
                        : theme.colors.border,
                    width: isSelected || isToday ? 1.5 : theme.style.borderWidth,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$day',
                      style: theme.typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? theme.colors.primary : theme.colors.foreground,
                      ),
                    ),
                    if (entry != null && (entry.income > 0 || entry.expense > 0)) ...[
                      if (entry.income > 0)
                        DompetAmountText(
                          amount: entry.income,
                          type: TransactionType.income,
                          style: theme.typography.labelBadge,
                        ),
                      if (entry.expense > 0)
                        DompetAmountText(
                          amount: entry.expense,
                          type: TransactionType.expense,
                          style: theme.typography.labelBadge,
                        ),
                    ] else
                      Text(
                        '·',
                        style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('MMMM yyyy').format(focusedDate),
          style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
