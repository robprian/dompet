import 'package:dompet/core/enums.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class RecurringPeriodChip extends StatelessWidget {
  const RecurringPeriodChip({required this.period, super.key});

  final RecurringPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = switch (period) {
      RecurringPeriod.daily => t.recurring.periodDaily,
      RecurringPeriod.weekly => t.recurring.periodWeekly,
      RecurringPeriod.monthly => t.recurring.periodMonthly,
      RecurringPeriod.yearly => t.recurring.periodYearly,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: theme.style.borderRadius.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.typography.labelBadge.copyWith(color: theme.colors.mutedForeground),
      ),
    );
  }
}
