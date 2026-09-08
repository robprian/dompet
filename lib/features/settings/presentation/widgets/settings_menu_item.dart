import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class SettingsMenuItem extends StatelessWidget with FItemMixin {
  const SettingsMenuItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FItem(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.theme.typography.bodySecondary.copyWith(color: context.theme.colors.mutedForeground),
            )
          : null,
      prefix: DompetIcon(
        icon: icon,
        size: DompetIconSize.small,
      ),
      suffix: trailing ?? Icon(FPhosphorIcons.caretRight, color: context.theme.colors.mutedForeground),
      onPress: onTap,
    );
  }
}
