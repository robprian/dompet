import 'package:dompet/core/extensions/num_extension.dart';
import 'package:dompet/features/reports/domain/services/report_analytics_service.dart';
import 'package:dompet/features/reports/presentation/controllers/report_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Sankey-style money flow: income sources → accounts → uses (categories,
/// savings, debt), driven by real transactions in the active period.
///
/// Implemented with proportional bars + connectors (no canvas) so it stays
/// readable on mobile and works with long labels. The whole diagram scrolls
/// horizontally when the viewport is narrow.
class ReportMoneyFlowDiagram extends ConsumerWidget {
  const ReportMoneyFlowDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = context.t.reports;
    final flow = ref.watch(reportProvider).data.moneyFlow;

    if (!flow.hasData) {
      return FCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Text(
              t.noData,
              style: theme.typography.bodyPrimary.copyWith(color: theme.colors.mutedForeground),
            ),
          ),
        ),
      );
    }

    final incomeTotal = flow.incomeNodes.fold<double>(0, (sum, node) => sum + node.amount);
    final useTotal = flow.expenseNodes.fold<double>(0, (sum, node) => sum + node.amount);
    final maxTotal = [incomeTotal, useTotal, flow.totalInflow, 1.0].reduce((a, b) => a > b ? a : b);
    final incomeColor = theme.colors.app.income;
    final expenseColor = theme.colors.app.expense;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Legend ────────────────────────────────────────────────────
            Row(
              children: [
                _LegendDot(color: incomeColor, label: t.moneyIn),
                const SizedBox(width: 14),
                _LegendDot(color: expenseColor, label: t.moneyOut),
              ],
            ),
            const SizedBox(height: 14),

            // ── Three-column Sankey ──────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _SankeyColumns(
                flow: flow,
                maxTotal: maxTotal,
                incomeColor: incomeColor,
                accountColor: theme.colors.primary,
                expenseColor: expenseColor,
                savingsColor: theme.colors.app.warning,
                surface: theme.colors.card,
                border: theme.colors.border,
              ),
            ),
            const SizedBox(height: 14),

            // ── Net balance summary ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: theme.style.borderRadius.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NetStat(
                      label: t.moneyIn,
                      value: flow.totalInflow,
                      color: incomeColor,
                    ),
                  ),
                  Container(width: 1, height: 28, color: theme.colors.border),
                  Expanded(
                    child: _NetStat(
                      label: t.moneyOut,
                      value: flow.totalOutflow,
                      color: expenseColor,
                    ),
                  ),
                  Container(width: 1, height: 28, color: theme.colors.border),
                  Expanded(
                    child: _NetStat(
                      label: t.netFlow,
                      value: flow.netBalance,
                      color: flow.netBalance >= 0 ? theme.colors.app.success : expenseColor,
                      signed: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SankeyColumns extends StatelessWidget {
  const _SankeyColumns({
    required this.flow,
    required this.maxTotal,
    required this.incomeColor,
    required this.accountColor,
    required this.expenseColor,
    required this.savingsColor,
    required this.surface,
    required this.border,
  });

  final ReportMoneyFlow flow;
  final double maxTotal;
  final Color incomeColor;
  final Color accountColor;
  final Color expenseColor;
  final Color savingsColor;
  final Color surface;
  final Color border;

  static const double _columnWidth = 150;
  static const double _columnGap = 12;
  static const double _rowGap = 6;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _columnWidth,
          child: _FlowColumn(
            header: context.t.reports.moneyIn,
            nodes: flow.incomeNodes,
            maxTotal: maxTotal,
            color: incomeColor,
            surface: surface,
            border: border,
            rowGap: _rowGap,
            theme: theme,
          ),
        ),
        const SizedBox(width: _columnGap),
        SizedBox(
          width: _columnWidth,
          child: _FlowColumn(
            header: context.t.reports.cashflow,
            nodes: flow.accountNodes,
            maxTotal: maxTotal,
            color: accountColor,
            surface: surface,
            border: border,
            rowGap: _rowGap,
            theme: theme,
          ),
        ),
        const SizedBox(width: _columnGap),
        SizedBox(
          width: _columnWidth,
          child: _FlowColumn(
            header: context.t.reports.moneyOut,
            nodes: flow.expenseNodes,
            maxTotal: maxTotal,
            color: expenseColor,
            savingsColor: savingsColor,
            surface: surface,
            border: border,
            rowGap: _rowGap,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _FlowColumn extends StatelessWidget {
  const _FlowColumn({
    required this.header,
    required this.nodes,
    required this.maxTotal,
    required this.color,
    required this.surface,
    required this.border,
    required this.rowGap,
    required this.theme,
    this.savingsColor,
  });

  final String header;
  final List<ReportFlowNode> nodes;
  final double maxTotal;
  final Color color;
  final Color? savingsColor;
  final Color surface;
  final Color border;
  final double rowGap;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          header.toUpperCase(),
          style: theme.typography.labelBadge.copyWith(color: theme.colors.mutedForeground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        if (nodes.isEmpty)
          _FlowNodeCard(
            node: const ReportFlowNode(id: '_empty', label: '—', amount: 0),
            maxTotal: maxTotal,
            color: color,
            surface: surface,
            border: border,
            theme: theme,
          )
        else
          for (var i = 0; i < nodes.length; i++) ...[
            _FlowNodeCard(
              node: nodes[i],
              maxTotal: maxTotal,
              color: nodes[i].id.startsWith('__') ? (savingsColor ?? color) : color,
              surface: surface,
              border: border,
              theme: theme,
            ),
            if (i != nodes.length - 1) SizedBox(height: rowGap),
          ],
      ],
    );
  }
}

class _FlowNodeCard extends StatelessWidget {
  const _FlowNodeCard({
    required this.node,
    required this.maxTotal,
    required this.color,
    required this.surface,
    required this.border,
    required this.theme,
  });

  final ReportFlowNode node;
  final double maxTotal;
  final Color color;
  final Color surface;
  final Color border;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ratio = maxTotal > 0 ? (node.amount / maxTotal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: theme.style.borderRadius.md,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  node.label,
                  style: theme.typography.bodySecondary.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                node.amount.toCompactFormat(),
                style: theme.typography.caption.copyWith(
                  color: theme.colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LayoutBuilder(
            builder: (context, constraints) => Container(
              height: 5,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio == 0 ? 0.02 : ratio,
                  child: Container(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetStat extends StatelessWidget {
  const _NetStat({required this.label, required this.value, required this.color, this.signed = false});

  final String label;
  final double value;
  final Color color;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        Text(
          label,
          style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${signed && value >= 0 ? '+' : ''}${value.toCompactFormat()}',
            style: theme.typography.bodySecondary.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground)),
      ],
    );
  }
}
