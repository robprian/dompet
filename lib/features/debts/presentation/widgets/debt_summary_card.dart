import 'package:dompet/core/enums.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_hero_card.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({required this.debts, required this.isPayable, super.key});

  final List<DebtModel> debts;
  final bool isPayable;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final debtColor = theme.colors.app.expense;
    final loanColor = theme.colors.app.income;
    final cardColor = isPayable ? debtColor : loanColor;

    var totalAmount = 0;
    var totalRemaining = 0;
    var paidCount = 0;

    for (final d in debts) {
      totalAmount += d.amount;
      totalRemaining += d.remainingAmount;
      if (d.status == DebtStatus.paid) paidCount++;
    }

    final overallProgress = totalAmount > 0 ? ((totalAmount - totalRemaining) / totalAmount).clamp(0.0, 1.0) : 0.0;

    return DompetHeroCard(
      cardColor: cardColor,
      pills: [
        DompetHeroCardPill(
          icon: isPayable ? FPhosphorIcons.arrowUpRight : FPhosphorIcons.arrowDownLeft,
          label: isPayable ? t.debts.owedCount(count: debts.length) : t.debts.receivableCount(count: debts.length),
        ),
        if (paidCount > 0)
          DompetHeroCardPill(
            icon: FPhosphorIcons.checkCircle,
            label: t.debts.settled(count: paidCount),
          ),
      ],
      title: t.debts.outstanding,
      amount: DompetAmountText(
        amount: totalRemaining,
        type: isPayable ? TransactionType.expense : TransactionType.income,
        style: theme.typography.display.sm.copyWith(
          color: theme.colors.primaryForeground,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          height: 1,
        ),
      ),
      progress: overallProgress,
      leftSubAmount: DompetHeroCardSubAmount(
        label: t.debts.paid,
        amount: totalAmount - totalRemaining,
        icon: FPhosphorIcons.checkCircle,
        type: isPayable ? TransactionType.expense : TransactionType.income,
      ),
      rightSubAmount: DompetHeroCardSubAmount(
        label: t.debts.principal,
        amount: totalAmount,
        icon: FPhosphorIcons.handshake,
        type: isPayable ? TransactionType.expense : TransactionType.income,
      ),
    );
  }
}
