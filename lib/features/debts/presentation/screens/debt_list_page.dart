import 'package:dompet/core/enums.dart';
import 'package:dompet/features/debts/presentation/controllers/debt_list_notifier.dart';
import 'package:dompet/features/debts/presentation/widgets/debt_list_content.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Overview page listing all active and settled debts (borrowed) and loans (lent).
class DebtListPage extends ConsumerWidget {
  const DebtListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);

    return FScaffold(
      header: DompetHeader(
        title: t.debts.debtsLoans,
        showBack: true,
      ),
      child: debtsAsync.when(
        data: (allDebts) {
          final iOweList = allDebts.where((d) => d.type == DebtType.debt).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final theyOweList = allDebts.where((d) => d.type == DebtType.loan).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: FTabs(
              children: [
                FTabEntry(
                  label: Text(t.debts.iOwe),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DebtListContent(
                      debts: iOweList,
                      isPayable: true,
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.05, end: 0),
                  ),
                ),
                FTabEntry(
                  label: Text(t.debts.theyOwe),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DebtListContent(
                      debts: theyOweList,
                      isPayable: false,
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.05, end: 0),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            t.debts.failedToLoadDebts(error: error.toString()),
            style: context.theme.typography.body.md.copyWith(
              color: context.theme.colors.destructive,
            ),
          ),
        ),
      ),
    );
  }
}
