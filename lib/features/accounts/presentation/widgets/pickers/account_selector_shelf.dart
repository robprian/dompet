import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_pill.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class AccountSelectorShelf extends StatelessWidget {
  const AccountSelectorShelf({
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountSelected,
    super.key,
  });

  final List<AccountModel> accounts;
  final String? selectedAccountId;
  final ValueChanged<AccountModel> onAccountSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (accounts.isEmpty) {
      return SizedBox(
        height: 38,
        child: Center(
          child: Text(
            t.accounts.noAccountsFound1,
            style: theme.typography.bodyPrimary,
          ),
        ),
      );
    }

    final parents = accounts.where((a) => !a.isPocket).toList();
    final selectedAcc = accounts.where((a) => a.id == selectedAccountId).firstOrNull;
    final activeParentId = selectedAcc?.isPocket == true ? selectedAcc!.parentId : selectedAcc?.id;
    final pockets = activeParentId != null
        ? accounts.where((a) => a.parentId == activeParentId).toList()
        : <AccountModel>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DompetPillScrollRow(
          children: parents.map((acc) {
            final isSel = activeParentId == acc.id;
            final accColor = Color(int.parse(acc.color?.replaceFirst('#', '0xFF') ?? '0xFF94A3B8'));
            return DompetPill(
              icon: IconUtil.getIcon(acc.icon),
              label: acc.name,
              color: accColor,
              isSelected: isSel,
              onTap: () => onAccountSelected(acc),
            );
          }).toList(),
        ),
        if (pockets.isNotEmpty) ...[
          const SizedBox(height: 6),
          DompetPillScrollRow(
            children: pockets.map((pocket) {
              final isSel = selectedAccountId == pocket.id;
              final pocketColor = Color(int.parse(pocket.color?.replaceFirst('#', '0xFF') ?? '0xFF94A3B8'));
              return DompetPill(
                icon: IconUtil.getIcon(pocket.icon),
                label: pocket.name,
                color: pocketColor,
                isSelected: isSel,
                isChild: true,
                onTap: () => onAccountSelected(pocket),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
