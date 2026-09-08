import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// DompetCategorySelector is a custom sheet for selecting a category.
/// It uses a split-tap UX where tapping the chevron expands the children,
/// while tapping the row selects the item and closes the sheet.
class DompetCategorySelector extends HookWidget {
  /// Creates a DompetCategorySelector.
  const DompetCategorySelector({
    required this.categories,
    super.key,
  });

  /// The list of categories to choose from.
  final List<CategoryModel> categories;

  /// Utility to show this selector as a sheet.
  static Future<CategoryModel?> show(
    BuildContext context, {
    required List<CategoryModel> categories,
  }) {
    return showDompetSheet<CategoryModel>(
      context: context,
      builder: (context) => DompetSheet(
        title: t.shared.selectCategory,
        child: DompetCategorySelector(categories: categories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            t.shared.noCategoriesAvailable,
            style: context.theme.typography.body.lg,
          ),
        ),
      );
    }

    // Group categories into parents and children
    final parents = categories.where((c) => c.parentId == null).toList();
    final childrenMap = <String, List<CategoryModel>>{};
    for (final c in categories) {
      if (c.parentId != null) {
        childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }

    final expandedStates = useState<Set<String>>({});

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: parents.length,
        itemBuilder: (context, index) {
          final parent = parents[index];
          final children = childrenMap[parent.id] ?? [];
          final isExpanded = expandedStates.value.contains(parent.id);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Parent Row
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.theme.colors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(parent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              DompetIcon(
                                icon: IconUtil.getIcon(parent.icon),
                                color: parent.color?.toColor() ?? context.theme.colors.primary,
                                size: DompetIconSize.small,
                                useThemeBorderColor: true,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  parent.name,
                                  style: context.theme.typography.titleItem,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (children.isNotEmpty)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final current = Set<String>.from(expandedStates.value);
                          if (isExpanded) {
                            current.remove(parent.id);
                          } else {
                            current.add(parent.id);
                          }
                          expandedStates.value = current;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(
                            isExpanded ? FPhosphorIcons.caretUp : FPhosphorIcons.caretDown,
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Children Rows
              if (isExpanded)
                ...children.map((child) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(child),
                    child: Container(
                      padding: const EdgeInsets.only(left: 48, right: 16, top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: context.theme.colors.border,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          DompetIcon(
                            icon: IconUtil.getIcon(child.icon),
                            color: child.color?.toColor() ?? context.theme.colors.primary,
                            size: DompetIconSize.small,
                            useThemeBorderColor: true,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              child.name,
                              style: context.theme.typography.titleItem,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
