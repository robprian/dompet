import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/core/utils/logger.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'detection_review_notifier.g.dart';

/// Streams candidates awaiting review.
@riverpod
Stream<List<TransactionDetectionModel>> pendingDetections(Ref ref) {
  final repo = ref.watch(detectionRepositoryProvider);
  return repo.watchPending();
}

/// Counts candidates awaiting review.
@riverpod
Stream<int> pendingDetectionCount(Ref ref) {
  final repo = ref.watch(detectionRepositoryProvider);
  return repo.watchPending().map((items) => items.length);
}

/// Handles saving or ignoring reviewed detection candidates.
@riverpod
class DetectionReviewNotifier extends _$DetectionReviewNotifier {
  @override
  Future<void> build() async {}

  /// Imports a candidate as a real transaction and records review choices.
  Future<void> importAsTransaction(
    TransactionDetectionModel detection, {
    required String accountId,
    String? categoryId,
    int? amount,
    String? note,
  }) async {
    final now = DateTime.now().toUtc();
    final party = detection.merchant ?? detection.counterparty;
    final resolvedAmount = amount ?? detection.amount;
    String resolvedNote;
    if (note?.trim().isNotEmpty == true) {
      resolvedNote = note!.trim();
    } else {
      final parts = <String>[
        if (party != null && party.isNotEmpty) party,
        if (detection.referenceId != null) 'Ref: ${detection.referenceId}',
      ];
      resolvedNote = parts.join(' · ');
    }

    final transactionId = const Uuid().v7();
    final transaction = TransactionModel(
      id: transactionId,
      accountId: accountId,
      type: _toLedgerType(detection.type),
      amount: resolvedAmount,
      transactionDate: detection.occurredAt,
      createdAt: now,
      updatedAt: now,
      note: resolvedNote.isEmpty ? null : resolvedNote,
      items: [
        TransactionItemModel(
          id: const Uuid().v7(),
          transactionId: transactionId,
          amount: resolvedAmount,
          categoryId: categoryId,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final result = await ref.read(transactionRepositoryProvider).createTransaction(transaction);
    switch (result) {
      case Success():
        await _resolve(detection, DetectionStatus.imported, accountId: accountId, categoryId: categoryId);
        if (categoryId != null && (detection.merchant?.isNotEmpty ?? false)) {
          await ref
              .read(detectionRepositoryProvider)
              .learnMerchantCategory(merchant: detection.merchant!, categoryId: categoryId);
        }
      case ErrorResult(:final error):
        talker.error('Failed to import detected transaction', error);
    }
  }

  /// Marks a candidate as ignored.
  Future<void> ignore(TransactionDetectionModel detection) async {
    await _resolve(detection, DetectionStatus.ignored);
  }

  Future<void> _resolve(
    TransactionDetectionModel detection,
    DetectionStatus status, {
    String? accountId,
    String? categoryId,
  }) async {
    await ref
        .read(detectionRepositoryProvider)
        .resolveCandidate(id: detection.id, status: status, accountId: accountId, categoryId: categoryId);
  }

  static TransactionType _toLedgerType(DetectionTransactionType type) {
    return switch (type) {
      DetectionTransactionType.income => TransactionType.income,
      DetectionTransactionType.expense => TransactionType.expense,
      DetectionTransactionType.transfer => TransactionType.transfer,
    };
  }
}
