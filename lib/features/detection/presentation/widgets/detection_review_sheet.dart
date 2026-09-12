import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_money_field.dart';
import 'package:dompet/shared/widgets/dompet_category_selector.dart';
import 'package:dompet/shared/widgets/dompet_pocket_selector.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet for reviewing a locally detected transaction.
class DetectionReviewSheet extends HookConsumerWidget {
  /// Creates the review sheet.
  const DetectionReviewSheet({required this.detection, super.key});

  /// The candidate under review.
  final TransactionDetectionModel detection;

  /// Shows the sheet for [detection].
  static Future<void> show(BuildContext context, TransactionDetectionModel detection) {
    return showDompetSheet<void>(
      context: context,
      builder: (context) => DetectionReviewSheet(detection: detection),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final accounts = ref.watch(accountsStreamProvider).value ?? <AccountModel>[];
    final categories = ref.watch(categoryListProvider).value ?? <CategoryModel>[];
    final accountId = useState<String?>(detection.accountId);
    final categoryId = useState<String?>(detection.categoryId);
    final amountController = useTextEditingController(
      text: ref.read(numberFormatServiceProvider).formatInt(detection.amount),
    );
    final noteController = useTextEditingController();

    final selectedAccount = _findAccount(accounts, accountId.value);
    final selectedCategory = _findCategory(categories, categoryId.value);

    final ledgerType = detection.type == DetectionTransactionType.income
        ? TransactionType.income
        : TransactionType.expense;

    return DompetSheet(
      title: context.t.settings.reviewQueueReview,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DompetAmountText(
              amount: detection.amount,
              type: ledgerType,
              style: theme.typography.amountSection,
            ),
            const SizedBox(height: 4),
            Text(
              '${detection.merchant ?? detection.counterparty ?? detection.sourcePackage} · ${detection.methodLabel}',
              style: theme.typography.bodySecondary.copyWith(color: theme.colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${context.t.settings.reviewQueueConfidence}: ${(detection.confidence * 100).round()}%',
              style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
            ),
            const SizedBox(height: 16),
            DompetMoneyField(
              controller: amountController,
              hint: context.t.settings.reviewQueueAmount,
            ),
            const SizedBox(height: 12),
            FButton(
              onPress: () async {
                final picked = await DompetPocketSelector.show(
                  context,
                  accounts: accounts,
                  selectedId: accountId.value,
                );
                if (picked != null) accountId.value = picked.id;
              },
              child: Text(
                selectedAccount?.name ?? context.t.settings.reviewQueueAccount,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            FButton(
              onPress: () async {
                final picked = await DompetCategorySelector.show(context, categories: categories);
                if (picked != null) categoryId.value = picked.id;
              },
              child: Text(
                selectedCategory?.name ?? context.t.settings.reviewQueueCategory,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            FTextField(
              hint: 'Note',
              control: FTextFieldControl.managed(controller: noteController),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: () async {
                      await ref.read(detectionReviewProvider.notifier).ignore(detection);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(context.t.settings.reviewQueueIgnore),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    onPress: () async {
                      if (accountId.value == null) return;
                      final amount = ref.read(numberFormatServiceProvider).parse(amountController.text);
                      if (amount == null || amount <= 0) return;
                      await ref
                          .read(detectionReviewProvider.notifier)
                          .importAsTransaction(
                            detection,
                            accountId: accountId.value!,
                            categoryId: categoryId.value,
                            amount: amount.round(),
                            note: noteController.text,
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(context.t.settings.reviewQueueSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static AccountModel? _findAccount(List<AccountModel> accounts, String? id) {
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  static CategoryModel? _findCategory(List<CategoryModel> categories, String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}
