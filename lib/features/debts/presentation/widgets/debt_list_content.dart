import 'package:dompet/features/debts/domain/debt_model.dart';
import 'package:dompet/features/debts/presentation/widgets/debt_card.dart';
import 'package:dompet/features/debts/presentation/widgets/debt_form_sheet.dart';
import 'package:dompet/features/debts/presentation/widgets/debt_summary_card.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_empty_view.dart';
import 'package:dompet/shared/widgets/dompet_section_label.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

class DebtListContent extends StatelessWidget {
  const DebtListContent({
    required this.debts,
    required this.isPayable,
    super.key,
  });

  final List<DebtModel> debts;
  final bool isPayable;

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return Builder(
        builder: (context) => DompetEmptyViewCentered(
          icon: isPayable ? FPhosphorIcons.arrowUpRight : FPhosphorIcons.arrowDownLeft,
          title: isPayable ? t.debts.noDebtsRecorded : t.debts.noLoansRecorded,
          subtitle: isPayable
              ? t.debts.trackMoneyYouOweToOthersAndLogRepayments
              : t.debts.trackMoneyOthersOweYouAndLogCollections,
          actionLabel: t.debts.addRecord,
          actionKey: const Key('debt-add-button'),
          onAction: () => DebtFormSheet.show(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DebtSummaryCard(debts: debts, isPayable: isPayable),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DompetSectionLabel(
              title: isPayable ? t.debts.payable : t.debts.receivable,
            ),
            Builder(
              builder: (context) => GestureDetector(
                key: const Key('debt-add-button'),
                onTap: () => DebtFormSheet.show(context),
                child: Row(
                  children: [
                    Icon(FPhosphorIcons.plus, size: 14, color: context.theme.colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      t.debts.addRecord,
                      style: context.theme.typography.bodySecondary.copyWith(
                        color: context.theme.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: debts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => DebtCard(debt: debts[index]),
          ),
        ),
      ],
    );
  }
}
