import 'package:dompet/core/enums.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/features/detection/presentation/widgets/detection_review_sheet.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_amount_text.dart';
import 'package:dompet/shared/widgets/dompet_empty_view.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Lists locally detected transactions awaiting user review.
class DetectionReviewPage extends ConsumerWidget {
  /// Creates the review page.
  const DetectionReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(pendingDetectionsProvider);

    return FScaffold(
      header: DompetHeader(title: context.t.settings.reviewQueue, showBack: true),
      child: switch (itemsAsync) {
        AsyncData(:final value) when value.isEmpty => DompetEmptyView(
            icon: FPhosphorIcons.notification,
            title: context.t.settings.reviewQueueEmpty,
          ),
        AsyncData(:final value) => ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: value.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _DetectionTile(detection: value[index]),
          ),
        _ => const Center(child: FCircularProgress()),
      },
    );
  }
}

class _DetectionTile extends ConsumerWidget {
  const _DetectionTile({required this.detection});

  final TransactionDetectionModel detection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final type = detection.type == DetectionTransactionType.income
        ? TransactionType.income
        : TransactionType.expense;
    final party = detection.partyName ?? detection.sourcePackage;

    return FCard(
      child: GestureDetector(
      onTap: () => DetectionReviewSheet.show(context, detection),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party, style: theme.typography.bodyPrimary, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: theme.style.borderRadius.md,
                      ),
                      child: Text(detection.methodLabel, style: theme.typography.caption),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(detection.confidence * 100).round()}%',
                      style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DompetAmountText(amount: detection.amount, type: type),
        ],
      ),
      ),
    );
  }
}
