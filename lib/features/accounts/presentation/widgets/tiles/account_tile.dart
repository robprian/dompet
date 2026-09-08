import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget with FTileMixin {
  const AccountTile({
    required this.account,
    this.pocketCount = 0,
    super.key,
  });

  final AccountModel account;
  final int pocketCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    Color accountColor;
    try {
      accountColor = account.color?.toColor() ?? theme.colors.primary;
    } on Object catch (_) {
      accountColor = theme.colors.primary;
    }

    return FInheritedItemData.merge(
      index: 1, // Force FTile to not render first item borders
      last: false, // Force FTile to not render last item borders
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colors.border,
            ),
          ),
        ),
        child: FTile(
          prefix: DompetIcon(
            icon: IconUtil.getIcon(account.icon),
            color: accountColor,
          ),
          title: Text(
            account.name,
            style: theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: pocketCount > 0
              ? Text(
                  t.accounts.pocketsCount(count: pocketCount),
                  style: theme.typography.bodyPrimary.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
