import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/recurring/domain/recurring_model.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_detail_notifier.g.dart';

@riverpod
Stream<List<TransactionModel>> recurringTransactions(Ref ref, RecurringTransactionModel recurring) {
  return ref
      .read(transactionRepositoryProvider)
      .watchTransactions(
        recurringIds: {recurring.id},
      )
      .asyncMap((result) {
        return switch (result) {
          Success(value: final transactions) => transactions,
          ErrorResult(error: final failure) => Future.error(failure, StackTrace.current),
        };
      });
}
