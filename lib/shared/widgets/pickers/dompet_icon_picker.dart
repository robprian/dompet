import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DompetIconPicker extends HookWidget {
  const DompetIconPicker({
    required this.selectedIcon,
    required this.onIconSelected,
    this.accountProvidersOnly = false,
    super.key,
  });

  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  /// Shows the bundled bank, e-wallet, and investment providers.
  final bool accountProvidersOnly;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final selectedCategory = useState<IconCategory>(IconUtil.categories.first);
    final providerType = useState(AccountProviderType.bank);
    final providers = accountProvidersOnly ? IconUtil.providersOf(providerType.value) : const <AccountProvider>[];
    final entries = accountProvidersOnly
        ? <Object>[...providers]
        : <Object>[...selectedCategory.value.icons.entries];

    final providerLabels = <AccountProviderType, String>{
      AccountProviderType.bank: 'Bank',
      AccountProviderType.ewallet: 'E-Wallet',
      AccountProviderType.investment: 'Investasi',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (accountProvidersOnly)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AccountProviderType.values.map((type) {
                final isSelected = providerType.value == type;
                final label = providerLabels[type]!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => providerType.value = type,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colors.primary : theme.colors.secondary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        label,
                        style: theme.typography.bodyPrimary.copyWith(
                          color: isSelected ? theme.colors.primaryForeground : theme.colors.secondaryForeground,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: IconUtil.categories.map((category) {
                final isSelected = selectedCategory.value.name == category.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => selectedCategory.value = category,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colors.primary : theme.colors.secondary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        category.name,
                        style: theme.typography.bodyPrimary.copyWith(
                          color: isSelected ? theme.colors.primaryForeground : theme.colors.secondaryForeground,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: entries.map((entry) {
            final iconName = switch (entry) {
              AccountProvider(:final id) => id,
              MapEntry<String, IconData>(:final key) => key,
              _ => '',
            };
            final iconData = switch (entry) {
              MapEntry<String, IconData>(:final value) => value,
              _ => null,
            };
            final isSelected = selectedIcon == iconName;

            return GestureDetector(
              onTap: () => onIconSelected(iconName),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? theme.colors.primary.withValues(alpha: 0.1) : theme.colors.background,
                  borderRadius: theme.style.borderRadius.md,
                  border: Border.all(
                    color: isSelected ? theme.colors.primary : theme.colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: switch (entry) {
                  AccountProvider(:final assetPath) => Image.asset(
                      assetPath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  MapEntry<String, IconData>() => Icon(
                      iconData!,
                      color: isSelected ? theme.colors.primary : theme.colors.foreground,
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
