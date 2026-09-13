import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/accounts/presentation/controllers/account_list_notifier.dart';
import 'package:dompet/features/accounts/presentation/widgets/pickers/account_selector_shelf.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_detail_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_form_label.dart';
import 'package:dompet/shared/widgets/dompet_money_field.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet for allocating savings into a goal.
///
/// The movement is recorded as a transfer from a source account into the goal's
/// linked pocket, so it never appears as an expense and never double-counts.
class GoalContributionSheet extends HookConsumerWidget {
  const GoalContributionSheet({required this.goal, super.key});

  /// Goal receiving the funds.
  final GoalModel goal;

  /// Shows the contribution sheet.
  static Future<bool?> show(BuildContext context, GoalModel goal) {
    return showDompetSheet<bool>(
      context: context,
      builder: (context) => GoalContributionSheet(goal: goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(goalDetailProvider.notifier);
    final accountsState = ref.watch(accountListProvider);
    final accounts =
        (accountsState.asData?.value.accounts ?? const <AccountModel>[])
            .where((a) => a.isActive && a.id != goal.accountId && a.type != AccountType.goal)
            .toList()
          ..sort((a, b) => a.sort.compareTo(b.sort));

    final selectedAccountId = useState<String?>(accounts.isNotEmpty ? accounts.first.id : null);
    final amount = useState(0);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final amountController = useTextEditingController();
    final isSubmitting = useState(false);
    final errorMessage = useState<String?>(null);

    final selectedAccount = accounts.where((a) => a.id == selectedAccountId.value).firstOrNull;

    Future<void> submit() async {
      final account = selectedAccount;
      if (account == null || isSubmitting.value) return;
      if (!(formKey.currentState?.validate() ?? false)) return;
      isSubmitting.value = true;
      errorMessage.value = null;
      final result = await notifier.contribute(goal: goal, source: account, amount: amount.value);
      if (!context.mounted) return;
      isSubmitting.value = false;
      switch (result) {
        case Success():
          Navigator.of(context).pop(true);
        case ErrorResult(error: final failure):
          errorMessage.value = failure.message;
      }
    }

    return DompetSheet(
      title: t.goals.addSavingsToGoal(goal: goal.name),
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DompetMoneyField(
                controller: amountController,
                label: DompetFormLabel(t.goals.contributionAmount),
                hint: '0',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => amount.value = value?.round() ?? 0,
                validator: (value) {
                  final parsed = ref.read(numberFormatServiceProvider).parse(value ?? '');
                  if (parsed == null || parsed <= 0) return t.goals.targetAmountGreaterThanZero;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DompetFormLabel(t.goals.sourceAccount),
              const SizedBox(height: 8),
              if (accounts.isEmpty)
                Text(
                  t.shared.noWalletsFoundPleaseCreateOneFirst,
                  style: context.theme.typography.bodySecondary.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                )
              else
                AccountSelectorShelf(
                  accounts: accounts,
                  selectedAccountId: selectedAccountId.value,
                  onAccountSelected: (account) => selectedAccountId.value = account.id,
                ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage.value!,
                  style: context.theme.typography.bodySecondary.copyWith(color: context.theme.colors.error),
                ),
              ],
              const SizedBox(height: 20),
              if (isSubmitting.value)
                const Center(child: FCircularProgress())
              else
                FButton(
                  onPress: accounts.isEmpty ? null : submit,
                  child: Text(t.goals.addSavings),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
