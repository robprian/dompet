import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryPickerSheet extends ConsumerWidget {
  const CategoryPickerSheet({super.key});

  static Future<CategoryModel?> show(BuildContext context) {
    return showDompetSheet<CategoryModel>(
      context: context,
      builder: (context) => DompetSheet(
        title: t.transactions.selectCategory,
        child: const CategoryPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).value ?? <CategoryModel>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: categories.map((cat) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  icon: IconUtil.getIcon(cat.icon),
                  color: cat.color?.toColor() ?? context.theme.colors.primary,
                  size: DompetIconSize.small,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    cat.name,
                    style: context.theme.typography.body.lg.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
