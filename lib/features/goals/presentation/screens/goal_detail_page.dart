import 'package:dompet/core/enums.dart';
import 'package:dompet/core/extensions/datetime_extension.dart';
import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/accounts/presentation/controllers/account_list_notifier.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_detail_notifier.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/goals/presentation/widgets/goal_contribution_sheet.dart';
import 'package:dompet/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:dompet/features/goals/presentation/widgets/goal_status_badge.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_empty_view.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/dompet_section_label.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Detail page presenting a savings goal as a concrete funding target:
/// target, saved, remaining, progress, target date, source pocket, and the
/// goal-only contribution history.
class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({required this.id, this.goal, super.key});

  final String id;
  final GoalModel? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalStateList = ref.watch(goalListStatesProvider);
    final activeGoalState = goalStateList.where((g) => g.goal.id == id).firstOrNull;

    if (activeGoalState == null) {
      return FScaffold(
        header: DompetHeader(title: t.goals.goalDetails, showBack: true),
        child: const Center(child: FCircularProgress()),
      );
    }

    final activeGoal = activeGoalState.goal;
    final theme = context.theme;
    final linkedAccounts = ref.watch(accountListProvider).asData?.value.accounts ?? const <AccountModel>[];
    final linkedPocket = linkedAccounts.where((a) => a.id == activeGoal.accountId).firstOrNull;
    final contributionsAsync = ref.watch(goalContributionsProvider(activeGoal));
    final isPast = activeGoal.status == GoalStatus.completed;

    return FScaffold(
      header: DompetHeader(
        title: t.goals.goalDetails,
        showBack: true,
        suffixes: [
          FHeaderAction(
            key: const Key('goal-edit-button'),
            icon: const Icon(FPhosphorIcons.pencilSimple, size: 20),
            onPress: () => GoalFormSheet.show(context, initialGoal: activeGoal),
          ),
          FHeaderAction(
            key: const Key('goal-delete-button'),
            icon: Icon(FPhosphorIcons.trash, size: 20, color: theme.colors.destructive),
            onPress: () async {
              final deleted = await ref
                  .read(goalDetailProvider.notifier)
                  .deleteGoal(context, activeGoal, currentBalance: activeGoalState.saved);
              if (deleted && context.mounted) context.pop();
            },
          ),
        ],
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _GoalHero(
              goal: activeGoal,
              state: activeGoalState,
              pocketName: linkedPocket?.name,
            ).animate().fade(duration: 320.ms).slideY(begin: 0.05, end: 0),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Facts: target / saved / remaining / date / source ───────────
          SliverToBoxAdapter(
            child: _GoalFacts(
              state: activeGoalState,
              targetDate: activeGoal.targetDate,
              pocketName: linkedPocket?.name,
            ).animate().fade(duration: 320.ms, delay: 60.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Primary CTA: Add Savings (allocation, not expense) ──────────
          if (!isPast)
            SliverToBoxAdapter(
              child: FButton(
                key: const Key('goal-add-savings-button'),
                onPress: () => GoalContributionSheet.show(context, activeGoal),
                prefix: const Icon(FPhosphorIcons.piggyBank, size: 18),
                child: Text(t.goals.addSavings),
              ).animate().fade(duration: 320.ms, delay: 100.ms),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Contribution history (goal-only, transfers) ─────────────────
          SliverToBoxAdapter(child: DompetSectionLabel(title: t.goals.contributions)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          contributionsAsync.when(
            data: (contributions) {
              if (contributions.isEmpty) {
                return SliverToBoxAdapter(
                  child: DompetEmptyViewCentered(
                    icon: FPhosphorIcons.piggyBank,
                    title: t.goals.noContributionsYet,
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contribution = contributions[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == contributions.length - 1 ? 0 : 10),
                      child: _ContributionTile(contribution: contribution, theme: theme),
                    );
                  },
                  childCount: contributions.length,
                ),
              );
            },
            error: (err, _) => SliverToBoxAdapter(child: Text(err.toString())),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: FCircularProgress()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Hero card: goal identity and progress at a glance.
class _GoalHero extends StatelessWidget {
  const _GoalHero({required this.goal, required this.state, this.pocketName});

  final GoalModel goal;
  final GoalItemState state;
  final String? pocketName;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = goal.color?.toColor() ?? theme.colors.primary;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DompetIcon(
                  icon: (state.isCompleted || state.isTargetReached)
                      ? FPhosphorIcons.checkCircle
                      : FPhosphorIcons.target,
                  color: state.isCompleted || state.isTargetReached ? theme.colors.app.success : accent,
                  size: DompetIconSize.large,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: theme.typography.titleCard,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (state.isCompleted)
                        GoalStatusBadge(label: t.goals.completed, color: theme.colors.app.success)
                      else if (state.isTargetReached)
                        GoalStatusBadge(label: t.goals.fullyFunded, color: theme.colors.app.success)
                      else
                        GoalStatusBadge(label: t.goals.inProgress, color: theme.colors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.goals.currentSaved,
                        style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                      ),
                      const SizedBox(height: 2),
                      DompetAmountText(
                        amount: state.saved,
                        type: TransactionType.income,
                        style: theme.typography.amountSection,
                      ),
                    ],
                  ),
                ),
                Text(
                  t.goals.percentOfTarget(percent: (state.progress * 100).round()),
                  style: theme.typography.bodySecondary.copyWith(
                    color: state.isTargetReached ? theme.colors.app.success : accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _GoalProgressBar(
              progress: state.progress,
              color: state.isTargetReached ? theme.colors.app.success : accent,
            ),
            if (state.isTargetReached && state.saved > goal.targetAmount) ...[
              const SizedBox(height: 10),
              Text(
                t.goals.goalOverfundedBy(
                  amount: (state.saved - goal.targetAmount).toString(),
                ),
                style: theme.typography.caption.copyWith(color: theme.colors.app.success),
              ),
            ],
            if (pocketName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(FPhosphorIcons.wallet, size: 14, color: theme.colors.mutedForeground),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${t.goals.linkedPocket}: $pocketName',
                      style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid of the goal's key numbers.
class _GoalFacts extends ConsumerWidget {
  const _GoalFacts({required this.state, this.targetDate, this.pocketName});

  final GoalItemState state;
  final DateTime? targetDate;
  final String? pocketName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final format = ref.watch(numberFormatServiceProvider);
    final facts = [
      (label: t.goals.targetAmount, value: format.formatInt(state.goal.targetAmount), icon: FPhosphorIcons.flag),
      (label: t.goals.remainingAmount, value: format.formatInt(state.remaining), icon: FPhosphorIcons.hourglass),
      (
        label: t.goals.targetDateLabel,
        value: targetDate != null ? DateFormat.yMMMd().format(targetDate!) : '—',
        icon: FPhosphorIcons.calendarBlank,
      ),
      (
        label: t.goals.sourceAccount,
        value: pocketName ?? '—',
        icon: FPhosphorIcons.wallet,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.9 : 1.7,
          children: [
            for (final fact in facts)
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(fact.icon, size: 16, color: theme.colors.mutedForeground),
                      const SizedBox(height: 6),
                      Text(
                        fact.label,
                        style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fact.value,
                        style: theme.typography.bodySecondary.copyWith(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A single contribution or withdrawal row.
class _ContributionTile extends StatelessWidget {
  const _ContributionTile({required this.contribution, required this.theme});

  final GoalContribution contribution;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isIncoming = contribution.isIncoming;
    final color = isIncoming ? theme.colors.app.income : theme.colors.mutedForeground;
    final label = isIncoming ? t.goals.contributionNote(goal: '') : t.goals.withdrawalNote(goal: '');
    final accountLabel = contribution.counterpartyName.isNotEmpty
        ? (isIncoming
              ? '${t.goals.fromAccount}: ${contribution.counterpartyName}'
              : '${t.goals.toAccount}: ${contribution.counterpartyName}')
        : contribution.occurredAt.toRelativeDateString();

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DompetIcon(
              icon: isIncoming ? FPhosphorIcons.arrowDownLeft : FPhosphorIcons.arrowUpRight,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.replaceAll(' · ', '').trim().isEmpty
                        ? (isIncoming ? t.goals.addSavings : t.goals.withdrawSavings)
                        : label,
                    style: theme.typography.bodySecondary.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$accountLabel · ${contribution.occurredAt.toFormattedDate()}',
                    style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DompetAmountText(
              amount: contribution.amount,
              type: isIncoming ? TransactionType.income : TransactionType.expense,
              style: theme.typography.bodySecondary.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressBar extends StatelessWidget {
  const _GoalProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 8,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
