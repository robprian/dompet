import 'dart:async';

import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dialogs/dompet_confirm_dialog.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/dompet_slidable_action.dart';
import 'package:dompet/shared/widgets/dompet_switch.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A list tile representing a category in a list view.
/// Shows the icon, name, and an optional toggle switch or sub-categories.
class CategoryTile extends ConsumerWidget with FTileMixin {
  const CategoryTile({
    required this.category,
    this.childCount = 0,
    this.onEdit,
    this.onDelete,
    this.onPress,
    this.onToggleActive,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  final CategoryModel category;
  final int childCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPress;
  final ValueChanged<bool>? onToggleActive;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // We get category color safely
    Color categoryColor;
    try {
      categoryColor = category.color?.toColor() ?? theme.colors.primary;
    } on Object catch (_) {
      categoryColor = theme.colors.primary;
    }

    final cardContent = FCard(
      clipBehavior: Clip.antiAlias,
      child: _buildTileContent(context, theme, categoryColor),
    );
    return Slidable(
      key: ValueKey(category.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          DompetSlidableAction(
            icon: FPhosphorIcons.trash,
            color: theme.colors.destructive,
            isDestructive: true,
            onPressed: () async {
              if (onDelete != null) {
                onDelete!();
              } else {
                final confirm = await showDompetConfirmDialog(
                  context,
                  title: t.categories.deleteCategory,
                  body: childCount > 0
                      ? t.categories.deleteConfirmWithChildren(count: childCount)
                      : t.categories.deleteConfirmNoChildren,
                  confirmText: t.categories.delete,
                );
                if (confirm == true) {
                  unawaited(ref.read(categoryListProvider.notifier).deleteCategory(category.id));
                }
              }
            },
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          DompetSlidableAction(
            icon: FPhosphorIcons.pencilSimple,
            color: theme.colors.primary,
            onPressed: () {
              onEdit?.call();
            },
          ),
        ],
      ),
      child: cardContent,
    );
  }

  Widget _buildTileContent(BuildContext context, FThemeData theme, Color categoryColor) {
    return FInheritedItemData.merge(
      index: 1, // Memaksa FTile menganggap dirinya bukan item pertama
      last: false, // Memaksa FTile menganggap dirinya bukan item terakhir
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPress,
        child: FTile(
          prefix: DompetIcon(
            icon: IconUtil.getIcon(category.icon),
            color: categoryColor,
          ),
          title: Text(
            category.name,
            style: theme.typography.titleItem,
          ),
          subtitle: childCount > 0
              ? Text(
                  t.categories.subcategoriesCount(count: childCount),
                  style: theme.typography.bodySecondary.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              : null,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onToggleActive != null)
                DompetSwitch(
                  value: category.isActive,
                  onChange: onToggleActive!,
                ),
              if (onPress != null) ...[
                if (onToggleActive != null) const SizedBox(width: 8),
                Icon(
                  FPhosphorIcons.caretRight,
                  color: theme.colors.mutedForeground,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
