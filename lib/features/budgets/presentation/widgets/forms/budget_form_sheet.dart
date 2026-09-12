import 'package:dompet/core/enums.dart';
import 'package:dompet/core/extensions/string_extension.dart';
import 'package:dompet/core/utils/icon_util.dart';
import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/features/accounts/presentation/controllers/account_list_notifier.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';
import 'package:dompet/features/budgets/presentation/controllers/budget_form_notifier.dart';
import 'package:dompet/features/budgets/presentation/widgets/pickers/date_picker_button.dart';
import 'package:dompet/features/budgets/presentation/widgets/pickers/period_selector.dart';
import 'package:dompet/features/budgets/presentation/widgets/tiles/scope_tile.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_category_selector.dart';
import 'package:dompet/shared/widgets/dompet_form_label.dart';
import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:dompet/shared/widgets/dompet_money_field.dart';
import 'package:dompet/shared/widgets/dompet_pocket_selector.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BudgetFormSheet extends HookConsumerWidget {
  const BudgetFormSheet({
    super.key,
    this.initialBudget,
    this.initialName,
    this.initialAmount,
    this.initialPeriod,
    this.initialCategoryId,
    this.initialAccountId,
  });

  final BudgetModel? initialBudget;
  final String? initialName;
  final int? initialAmount;
  final BudgetPeriod? initialPeriod;
  final String? initialCategoryId;
  final String? initialAccountId;

  static Future<void> show(
    BuildContext context, {
    BudgetModel? initialBudget,
    String? initialName,
    int? initialAmount,
    BudgetPeriod? initialPeriod,
    String? initialCategoryId,
    String? initialAccountId,
  }) {
    return showDompetSheet(
      context: context,
      builder: (context) => BudgetFormSheet(
        initialBudget: initialBudget,
        initialName: initialName,
        initialAmount: initialAmount,
        initialPeriod: initialPeriod,
        initialCategoryId: initialCategoryId,
        initialAccountId: initialAccountId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(budgetFormProvider.notifier);
    final state = ref.watch(budgetFormProvider);

    useEffect(() {
      Future.microtask(
        () => notifier.init(
          initialBudget,
          initialName: initialName,
          initialAmount: initialAmount,
          initialPeriod: initialPeriod,
          initialCategoryId: initialCategoryId,
          initialAccountId: initialAccountId,
        ),
      );
      return null;
    }, [initialBudget, initialName, initialAmount, initialPeriod, initialCategoryId, initialAccountId]);

    final nameController = useTextEditingController(text: initialBudget?.name ?? initialName ?? state.name);
    final amountController = useTextEditingController(
      text: initialBudget != null && initialBudget!.amount > 0
          ? ref.read(numberFormatServiceProvider).formatInt(initialBudget!.amount)
          : (initialAmount != null && initialAmount! > 0
                ? ref.read(numberFormatServiceProvider).formatInt(initialAmount)
                : (state.amount > 0 ? ref.read(numberFormatServiceProvider).formatInt(state.amount) : '')),
    );
    final resetDayController = useTextEditingController(
      text: initialBudget?.resetDay?.toString() ?? (state.resetDay != null ? state.resetDay.toString() : ''),
    );
    final alertThresholdController = useTextEditingController(
      text:
          initialBudget?.alertThreshold?.toString() ??
          (state.alertThreshold != null ? state.alertThreshold.toString() : ''),
    );

    useEffect(() {
      void onName() {
        if (state.name != nameController.text) notifier.setName(nameController.text);
      }

      void onResetDay() {
        final val = int.tryParse(resetDayController.text);
        if (state.resetDay != val) notifier.setResetDay(val);
      }

      void onAlertThreshold() {
        final val = int.tryParse(alertThresholdController.text);
        if (state.alertThreshold != val) notifier.setAlertThreshold(val);
      }

      nameController.addListener(onName);
      resetDayController.addListener(onResetDay);
      alertThresholdController.addListener(onAlertThreshold);
      return () {
        nameController.removeListener(onName);
        resetDayController.removeListener(onResetDay);
        alertThresholdController.removeListener(onAlertThreshold);
      };
    }, [nameController, amountController, resetDayController, alertThresholdController]);

    ref.listen(budgetFormProvider, (prev, next) {
      if (next.isSuccess && (prev?.isSuccess != true)) {
        Navigator.of(context).pop();
      }
      if (next.error != null && next.error != prev?.error) {
        showFToast(
          context: context,
          title: Text(next.error!),
          variant: FToastVariant.destructive,
        );
      }
    });

    final allAccounts = ref.watch(regularAccountListProvider).value?.accounts ?? [];
    final budgetAccounts = allAccounts;
    final allCategories = ref.watch(categoryListProvider).value ?? <CategoryModel>[];
    final expenseCategories = allCategories.where((c) => c.type == CategoryType.expense).toList();

    final selectedAccount = allAccounts.where((a) => a.id == state.accountId).firstOrNull;
    final selectedCategory = allCategories.where((c) => c.id == state.categoryId).firstOrNull;

    final isEditing = initialBudget != null;
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return DompetSheet(
      title: isEditing ? t.budgets.editBudget : t.budgets.newBudget,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FTextFormField(
              control: FTextFieldControl.managed(controller: nameController),
              label: Text(t.budgets.budgetName),
              hint: t.budgets.egGroceriesEntertainment,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => value == null || value.trim().isEmpty ? t.budgets.nameCannotBeEmpty : null,
            ),
            const SizedBox(height: 12),
            DompetMoneyField(
              controller: amountController,
              label: Text(t.budgets.spendingLimit),
              hint: '0',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) => notifier.setAmount(value?.round() ?? 0),
              validator: (value) {
                final amount = ref.read(numberFormatServiceProvider).parse(value ?? '');
                if (amount == null || amount <= 0) return t.budgets.amountGreaterThanZero;
                return null;
              },
            ),
            const SizedBox(height: 12),
            FTextFormField(
              control: FTextFieldControl.managed(controller: alertThresholdController),
              label: DompetFormLabel(t.budgets.alertThresholdLabel, isOptional: true),
              hint: t.budgets.eg80,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            FLabel(
              layout: FLabelLayout.vertical,
              label: Text(t.budgets.period),
              child: PeriodSelector(
                selected: state.period,
                onChanged: notifier.setPeriod,
              ),
            ),
            const SizedBox(height: 12),
            if (state.period == BudgetPeriod.monthly) ...[
              FTextFormField(
                control: FTextFieldControl.managed(controller: resetDayController),
                label: Text(t.budgets.resetDay),
                hint: '1',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],
            if (state.period == BudgetPeriod.custom) ...[
              DatePickerButton(
                date: state.endDate,
                onChanged: notifier.setEndDate,
              ),
              const SizedBox(height: 12),
            ],
            FLabel(
              layout: FLabelLayout.vertical,
              label: DompetFormLabel(t.budgets.scope, isOptional: true),
              child: FCard(
                child: Column(
                  children: [
                    ScopeTile(
                      defaultIcon: FPhosphorIcons.tag,
                      prefixWidget: selectedCategory != null
                          ? DompetIcon(
                              icon: IconUtil.getIcon(selectedCategory.icon),
                              color: selectedCategory.color?.toColor() ?? context.theme.colors.primary,
                              size: DompetIconSize.small,
                              useThemeBorderColor: true,
                            )
                          : null,
                      label: t.budgets.category,
                      value: selectedCategory?.name ?? t.budgets.anyCategory,
                      hasValue: selectedCategory != null,
                      onClear: () => notifier.setCategoryId(null),
                      onTap: () async {
                        final cat = await DompetCategorySelector.show(context, categories: expenseCategories);
                        if (cat != null) {
                          notifier.setCategoryId(cat.id);
                        }
                      },
                    ),
                    Divider(height: 1, color: context.theme.colors.border),
                    ScopeTile(
                      defaultIcon: FPhosphorIcons.wallet,
                      prefixWidget: selectedAccount != null
                          ? DompetIcon(
                              icon: IconUtil.getIcon(selectedAccount.icon),
                              color: selectedAccount.color?.toColor() ?? context.theme.colors.primary,
                              size: DompetIconSize.small,
                              useThemeBorderColor: true,
                            )
                          : null,
                      label: t.budgets.account,
                      value: selectedAccount?.name ?? t.budgets.anyAccount,
                      hasValue: selectedAccount != null,
                      onClear: () => notifier.setAccountId(null),
                      onTap: () async {
                        final acc = await DompetPocketSelector.show(context, accounts: budgetAccounts);
                        if (acc != null) {
                          notifier.setAccountId(acc.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (state.isSaving)
              const Center(child: FCircularProgress())
            else
              FButton(
                onPress: () {
                  if (formKey.currentState!.validate()) {
                    notifier.save();
                  }
                },
                child: Text(isEditing ? t.budgets.saveChanges : t.budgets.createBudget),
              ),
          ],
        ),
      ),
    );
  }
}
