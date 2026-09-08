import 'package:dompet/core/enums.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_progress_provider.dart';
import 'package:dompet/features/dashboard/presentation/controllers/balance_visibility_provider.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_hero_card.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BudgetSummaryCard extends ConsumerWidget {
  const BudgetSummaryCard({required this.budgets, super.key});

  final List<BudgetModel> budgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isBalanceVisible = ref.watch(balanceVisibilityProvider);

    // Aggregate totals from all watched budget progress providers.
    var totalLimit = 0;
    var totalSpent = 0;

    for (final budget in budgets) {
      totalLimit += budget.amount;
      final spentAsync = ref.watch(budgetProgressProvider(budget));
      totalSpent += spentAsync.asData?.value ?? 0;
    }

    final totalRemaining = totalLimit - totalSpent;
    final overallProgress = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final isOverLimit = overallProgress >= 1.0;

    return DompetHeroCard(
      pills: [
        DompetHeroCardPill(
          icon: FPhosphorIcons.chartPieSlice,
          label: '${budgets.length} budget${budgets.length > 1 ? 's' : ''}',
        ),
        if (isOverLimit)
          DompetHeroCardPill(
            icon: FPhosphorIcons.warning,
            label: t.budgets.overLimit,
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
      title: t.budgets.remaining,
      amount: DompetAmountText(
        amount: totalRemaining.abs(),
        type: totalRemaining >= 0 ? TransactionType.income : TransactionType.expense,
        isObscured: !isBalanceVisible,
        style: theme.typography.display.sm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          height: 1,
        ),
      ),
      progress: overallProgress,
      leftSubAmount: DompetHeroCardSubAmount(
        label: t.budgets.totalSpent,
        amount: totalSpent,
        icon: FPhosphorIcons.trendDown,
        type: TransactionType.expense,
        isObscured: !isBalanceVisible,
      ),
      rightSubAmount: DompetHeroCardSubAmount(
        label: t.budgets.totalLimit,
        amount: totalLimit,
        icon: FPhosphorIcons.chartBar,
        type: TransactionType.income,
        isObscured: !isBalanceVisible,
      ),
    );
  }
}
