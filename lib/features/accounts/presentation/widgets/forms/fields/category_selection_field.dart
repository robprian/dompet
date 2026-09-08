import 'package:dompet/features/accounts/presentation/controllers/account_form_notifier.dart';
import 'package:dompet/features/accounts/presentation/widgets/forms/sheets/category_selection_sheet.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class CategorySelectionField extends StatelessWidget {
  const CategorySelectionField({
    required this.notifier,
    required this.restrictedCategoryIds,
    super.key,
  });

  final AccountFormNotifier notifier;
  final Set<String> restrictedCategoryIds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDompetSheet<void>(
          context: context,
          builder: (context) => CategorySelectionSheet(
            notifier: notifier,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(
            color: restrictedCategoryIds.isNotEmpty
                ? context.theme.colors.primary.withValues(alpha: 0.5)
                : context.theme.colors.border,
          ),
          color: restrictedCategoryIds.isNotEmpty
              ? context.theme.colors.primary.withValues(alpha: 0.04)
              : context.theme.colors.muted.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: restrictedCategoryIds.isNotEmpty
                    ? context.theme.colors.primary.withValues(alpha: 0.12)
                    : context.theme.colors.muted.withValues(alpha: 0.6),
                borderRadius: context.theme.style.borderRadius.sm,
              ),
              child: Icon(
                FPhosphorIcons.tag,
                size: 18,
                color: restrictedCategoryIds.isNotEmpty
                    ? context.theme.colors.primary
                    : context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.accounts.allowedCategories,
                    style: context.theme.typography.bodyPrimary.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    restrictedCategoryIds.isEmpty
                        ? t.accounts.allCategoriesAllowed
                        : t.accounts.categoriesSelected(count: restrictedCategoryIds.length),
                    style: context.theme.typography.bodySecondary.copyWith(
                      color: restrictedCategoryIds.isNotEmpty
                          ? context.theme.colors.primary
                          : context.theme.colors.mutedForeground,
                      fontWeight: restrictedCategoryIds.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FPhosphorIcons.caretRight,
              size: 16,
              color: context.theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
