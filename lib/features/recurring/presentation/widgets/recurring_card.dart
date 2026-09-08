import 'dart:async';

import 'package:dompet/app/router/router.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/features/recurring/domain/recurring_model.dart';
import 'package:dompet/features/recurring/presentation/controllers/recurring_list_notifier.dart';
import 'package:dompet/features/recurring/presentation/widgets/recurring_form_sheet.dart';
import 'package:dompet/features/recurring/presentation/widgets/recurring_next_date_chip.dart';
import 'package:dompet/features/recurring/presentation/widgets/recurring_period_chip.dart';
import 'package:dompet/features/recurring/presentation/widgets/recurring_status_chip.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dialogs/dompet_confirm_dialog.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/dompet_slidable_action.dart';
import 'package:dompet/shared/widgets/dompet_switch.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecurringCard extends ConsumerWidget {
  const RecurringCard({
    required this.recurring,
    this.isInteractive = true,
    super.key,
  });

  final RecurringTransactionModel recurring;
  final bool isInteractive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final incomeColor = theme.colors.app.income;
    final expenseColor = theme.colors.app.expense;
    final transferColor = theme.colors.app.transfer;

    final typeColor = switch (recurring.type) {
      TransactionType.income => incomeColor,
      TransactionType.expense => expenseColor,
      TransactionType.transfer => transferColor,
    };

    final typeIcon = switch (recurring.type) {
      TransactionType.income => FPhosphorIcons.arrowDown,
      TransactionType.expense => FPhosphorIcons.arrowUp,
      TransactionType.transfer => FPhosphorIcons.arrowsLeftRight,
    };

    final cardContent = FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DompetIcon(icon: typeIcon, color: typeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recurring.note?.isNotEmpty == true ? recurring.note! : _typeLabel(recurring.type),
                        style: theme.typography.titleCard,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          RecurringPeriodChip(period: recurring.period),
                          const SizedBox(width: 6),
                          RecurringStatusChip(isActive: recurring.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Active toggle — tap area isolated from the card tap.
                if (isInteractive)
                  GestureDetector(
                    onTap: () {
                      ref.read(recurringListProvider.notifier).toggleActive(recurring.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: DompetSwitch(
                      value: recurring.isActive,
                      onChange: (_) => ref.read(recurringListProvider.notifier).toggleActive(recurring.id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DompetAmountText(
                  amount: recurring.amount,
                  type: recurring.type,
                  style: theme.typography.amountCard,
                ),
                RecurringNextDateChip(nextDate: recurring.nextDate),
              ],
            ),
          ],
        ),
      ),
    );

    if (!isInteractive) {
      return cardContent;
    }

    return Slidable(
      key: ValueKey(recurring.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          DompetSlidableAction(
            icon: FPhosphorIcons.trash,
            color: theme.colors.destructive,
            isDestructive: true,
            onPressed: () async {
              final confirm = await showDompetConfirmDialog(
                context,
                title: t.recurring.deleteSchedule,
                body: t
                    .recurring
                    .areYouSureYouWantToDeleteThisRecurringScheduleExistingGeneratedTransactionsWillNotBeDeleted,
                confirmText: t.recurring.delete,
              );
              if (confirm == true) {
                unawaited(ref.read(recurringListProvider.notifier).deleteRecurring(recurring.id));
              }
            },
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          DompetSlidableAction(
            icon: FPhosphorIcons.pencilSimple,
            color: theme.colors.primary,
            onPressed: () {
              RecurringFormSheet.show(context, initialRecurring: recurring);
            },
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => RecurringDetailRoute(recurring.id, $extra: recurring).push<void>(context),
        child: cardContent,
      ),
    );
  }

  String _typeLabel(TransactionType type) => switch (type) {
    TransactionType.income => t.recurring.recurringIncome,
    TransactionType.expense => t.recurring.recurringExpense,
    TransactionType.transfer => t.recurring.recurringTransfer,
  };
}
