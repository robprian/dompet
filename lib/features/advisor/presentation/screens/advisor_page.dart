import 'package:dompet/core/enums.dart';
import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:dompet/features/advisor/domain/allocation_engine.dart';
import 'package:dompet/features/advisor/presentation/controllers/advisor_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_empty_view.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Displays locally computed financial recommendations.
class AdvisorPage extends ConsumerWidget {
  /// Creates the advisor page.
  const AdvisorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(advisorProvider);

    return FScaffold(
      header: DompetHeader(title: context.t.settings.advisorTitle, showBack: true),
      child: switch ((state.isLoading, state.recommendations.isEmpty)) {
        (true, _) => const Center(child: FCircularProgress()),
        (_, true) => DompetEmptyView(
          icon: FPhosphorIcons.lightbulb,
          title: context.t.settings.advisorEmpty,
        ),
        _ => ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _AdvisorCard(recommendation: state.recommendations[index]),
        ),
      },
    );
  }
}

class _AdvisorCard extends HookConsumerWidget {
  const _AdvisorCard({required this.recommendation});

  final AdvisorRecommendationModel recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = context.t;
    final text = _text(t, recommendation);
    final icon = switch (recommendation.severity) {
      AdvisorSeverity.warning => FPhosphorIcons.warning,
      AdvisorSeverity.success => FPhosphorIcons.checkCircle,
      AdvisorSeverity.info => FPhosphorIcons.lightbulb,
    };

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DompetIcon(icon: icon, size: DompetIconSize.small),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text.title, style: theme.typography.titleItem),
              ),
              if (recommendation.amount != null)
                DompetAmountText(
                  amount: recommendation.amount!,
                  type: _amountType(recommendation),
                  style: theme.typography.amountTile,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text.message, style: theme.typography.bodySecondary.copyWith(color: theme.colors.mutedForeground)),
          if (recommendation.isSalaryRelated) const SizedBox(height: 12),
          if (recommendation.isSalaryRelated) _AllocationCard(income: recommendation.amount ?? 0),
        ],
      ),
    );
  }

  static TransactionType _amountType(AdvisorRecommendationModel recommendation) {
    return switch (recommendation.type) {
      AdvisorRecommendationType.salaryAllocation => TransactionType.income,
      _ => TransactionType.expense,
    };
  }

  static ({String title, String message}) _text(Translations t, AdvisorRecommendationModel recommendation) {
    switch (recommendation.type) {
      case AdvisorRecommendationType.salaryAllocation:
        return (
          title: t.settings.advisorAllocationTitle,
          message: t.settings.advisorAllocationBody(amount: '${recommendation.amount ?? 0}'),
        );
      case AdvisorRecommendationType.budget:
        final name = recommendation.relatedName ?? '';
        final percent = ((recommendation.ratio ?? 0) * 100).round();
        if (recommendation.ratio != null && recommendation.ratio! >= 1) {
          return (title: t.settings.advisorBudgetOver, message: t.settings.advisorBudgetOverBody(name: name));
        }
        return (
          title: t.settings.advisorBudgetAlmost,
          message: t.settings.advisorBudgetAlmostBody(
            name: name,
            percent: '$percent',
            remaining: '${recommendation.amount ?? 0}',
          ),
        );
      case AdvisorRecommendationType.overspending:
        return (title: t.settings.advisorLargeTitle, message: t.settings.advisorLargeBody);
      case AdvisorRecommendationType.largeTransaction:
        return (title: t.settings.advisorLargeTitle, message: t.settings.advisorLargeBody);
      case AdvisorRecommendationType.savingsRate:
        return (title: t.settings.advisorSavingsTitle, message: t.settings.advisorSavingsBody);
      case AdvisorRecommendationType.cashFlow:
        return (title: t.settings.advisorCashflowTitle, message: t.settings.advisorCashflowBody);
      case AdvisorRecommendationType.recurringExpense:
        return (
          title: t.settings.advisorBudgetAlmost,
          message: t.settings.advisorBudgetAlmostBody(name: '', percent: '', remaining: ''),
        );
    }
  }
}

class _AllocationCard extends ConsumerWidget {
  const _AllocationCard({required this.income});

  final int income;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final plan = AllocationEngine().allocate(income);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: theme.style.borderRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(theme, context.t.settings.allocationNeeds, plan.needs),
          const SizedBox(height: 4),
          _row(theme, context.t.settings.allocationSavings, plan.savings),
          const SizedBox(height: 4),
          _row(theme, context.t.settings.allocationDebt, plan.debt),
          const SizedBox(height: 4),
          _row(theme, context.t.settings.allocationLifestyle, plan.lifestyle),
          const SizedBox(height: 4),
          _row(theme, context.t.settings.allocationBuffer, plan.buffer),
        ],
      ),
    );
  }

  Widget _row(FThemeData theme, String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.typography.bodySecondary),
        Text(
          amount.abs().toString(),
          style: theme.typography.bodySecondary.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
