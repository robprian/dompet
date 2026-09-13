import 'package:dompet/core/enums.dart';
import 'package:dompet/features/reports/domain/services/report_analytics_service.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

/// Detail sheet for one money-flow trend point: money in, money out, and net.
class ReportCashflowDetailSheet extends StatelessWidget {
  const ReportCashflowDetailSheet({required this.point, super.key});

  final ReportTrendPoint point;

  /// Shows the detail sheet for [point].
  static Future<void> show(BuildContext context, ReportTrendPoint point) {
    return showDompetSheet<void>(
      context: context,
      fitContent: true,
      builder: (context) => ReportCashflowDetailSheet(point: point),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.reports;
    final net = point.income - point.expense;

    return DompetSheet(
      title: '${t.cashflow} · ${point.label}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(
              label: t.moneyIn,
              amount: point.income,
              isIncome: true,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: t.moneyOut,
              amount: point.expense,
              isIncome: false,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: t.netFlow,
              amount: net,
              isIncome: net >= 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.amount, required this.isIncome});

  final String label;
  final double amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: theme.typography.bodySecondary),
            ),
            DompetAmountText(
              amount: amount.abs().round(),
              type: isIncome ? TransactionType.income : TransactionType.expense,
              style: theme.typography.amountTile,
            ),
          ],
        ),
      ),
    );
  }
}
