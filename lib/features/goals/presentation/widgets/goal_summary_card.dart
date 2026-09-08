import 'package:dompet/core/enums.dart';
import 'package:dompet/features/dashboard/presentation/controllers/balance_visibility_provider.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_hero_card.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoalSummaryCard extends ConsumerWidget {
  const GoalSummaryCard({required this.totalGoals, super.key});

  final int totalGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final summary = ref.watch(goalSummaryProvider);
    final isBalanceVisible = ref.watch(balanceVisibilityProvider);

    return DompetHeroCard(
      pills: [
        DompetHeroCardPill(
          icon: FPhosphorIcons.target,
          label: t.goals.goalsCount(count: totalGoals),
        ),
        if (summary.targetReachedCount > 0)
          DompetHeroCardPill(
            icon: FPhosphorIcons.checkCircle,
            label: t.goals.fullyFundedCount(count: summary.targetReachedCount),
          ),
      ],
      trailing: GestureDetector(
        onTap: () => ref.read(balanceVisibilityProvider.notifier).toggle(),
        child: Icon(
          isBalanceVisible ? FPhosphorIcons.eye : FPhosphorIcons.eyeClosed,
          color: theme.colors.primaryForeground.withValues(alpha: 0.8),
          size: 20,
        ),
      ),
      title: t.goals.totalSaved,
      amount: DompetAmountText(
        amount: summary.totalSaved,
        type: TransactionType.income,
        isObscured: !isBalanceVisible,
        style: theme.typography.display.sm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          height: 1,
        ),
      ),
      progress: summary.overallProgress,
      leftSubAmount: DompetHeroCardSubAmount(
        label: t.goals.stillNeeded,
        amount: summary.remaining.abs(),
        icon: FPhosphorIcons.arrowCircleUp,
        type: summary.remaining >= 0 ? TransactionType.expense : TransactionType.income,
        isObscured: !isBalanceVisible,
      ),
      rightSubAmount: DompetHeroCardSubAmount(
        label: t.goals.totalTarget,
        amount: summary.totalTarget,
        icon: FPhosphorIcons.flag,
        type: TransactionType.income,
        isObscured: !isBalanceVisible,
      ),
    );
  }
}
