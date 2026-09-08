import 'package:dompet/features/accounts/presentation/controllers/account_list_notifier.dart';
import 'package:dompet/features/accounts/presentation/widgets/forms/account_form_sheet.dart';
import 'package:dompet/features/accounts/presentation/widgets/lists/account_grid.dart';
import 'package:dompet/features/accounts/presentation/widgets/lists/account_list_header.dart';
import 'package:dompet/features/accounts/presentation/widgets/sections/goal_account_section.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_empty_view.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/shared/widgets/dompet_section_label.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Top-level screen displaying all accounts categorized into regular accounts and goal pockets.
class AccountListPage extends HookConsumerWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regularListState = ref.watch(regularAccountListProvider);
    final goalListState = ref.watch(goalAccountListProvider);
    final metrics = ref.watch(accountMetricsProvider);

    final regularAggregates = regularListState.value?.aggregates ?? [];
    final goalAggregates = goalListState.value?.aggregates ?? [];
    final hasRegularAccounts = regularAggregates.isNotEmpty;
    final hasGoalAccounts = goalAggregates.isNotEmpty;

    return FScaffold(
      header: DompetHeader(title: t.accounts.accounts),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AccountListHeader(metrics: metrics).animateEntrance(),
          ),

          if (!hasRegularAccounts && !hasGoalAccounts)
            SliverFillRemaining(
              hasScrollBody: false,
              child: DompetEmptyViewCentered(
                icon: FPhosphorIcons.wallet,
                title: t.accounts.noAccountsYet,
                subtitle: t.accounts.tapTheButtonBelowToAddYourFirstAccount,
                actionLabel: t.accounts.addAccount,
                onAction: () => AccountFormSheet.show(context),
                actionKey: const Key('account-empty-add-button'),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DompetSectionLabel(title: t.accounts.mainAccounts),
                    GestureDetector(
                      key: const Key('account-add-button'),
                      onTap: () => AccountFormSheet.show(context),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(FPhosphorIcons.plus, size: 14, color: context.theme.colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            t.accounts.addAccount,
                            style: context.theme.typography.bodySecondary.copyWith(
                              color: context.theme.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animateEntrance(delay: 80.ms),
              ),
            ),

            if (hasRegularAccounts)
              SliverToBoxAdapter(
                child: AccountGrid(
                  aggregates: regularAggregates,
                  totalAssets: metrics.totalAssets,
                ).animateEntrance(delay: 120.ms),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(t.accounts.noMainAccountsYet),
                  ),
                ),
              ),

            if (hasGoalAccounts)
              SliverToBoxAdapter(
                child: GoalAccountSection(
                  aggregates: goalAggregates,
                  totalAssets: metrics.totalAssets,
                ).animateEntrance(delay: 160.ms),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Extensions ─────────────────────────────────────────────────────────────

extension EntranceAnimationExt on Widget {
  Widget animateEntrance({Duration delay = Duration.zero}) {
    return animate().fade(duration: 300.ms, delay: delay).slideY(begin: 0.05, end: 0);
  }
}
