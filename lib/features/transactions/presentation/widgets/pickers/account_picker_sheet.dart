import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/dashboard/presentation/controllers/dashboard_notifier.dart';
import 'package:dompet/shared/widgets/dompet_pocket_selector.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A convenience wrapper around [DompetPocketSelector] that reads the
/// account list from the dashboard provider and resolves to the selected account.
///
/// Used outside the transaction form (e.g., goal/debt flows) where the caller
/// only needs to call `.show()` and get back an [AccountModel].
class AccountPickerSheet extends ConsumerWidget {
  const AccountPickerSheet({super.key});

  /// Shows the account picker and returns the selected [AccountModel], or null
  /// if the user dismisses without selecting.
  static Future<AccountModel?> show(BuildContext context) async {
    final accounts = ProviderScope.containerOf(context).read(dashboardProvider).accounts;

    return DompetPocketSelector.show(
      context,
      accounts: accounts,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AccountPickerSheet is only used via .show() — this build is not reachable
    // in production, but kept for completeness.
    return const SizedBox.shrink();
  }
}
