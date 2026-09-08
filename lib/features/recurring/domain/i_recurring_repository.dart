import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/recurring/domain/recurring_model.dart';

abstract class IRecurringRepository {
  Future<Result<List<RecurringTransactionModel>, Failure>> getRecurringTransactions();
  Future<Result<List<RecurringTransactionModel>, Failure>> getActiveRecurringTransactions();

  /// Returns all active recurring transactions due on or before [asOf].
  Future<Result<List<RecurringTransactionModel>, Failure>> getDueRecurringTransactions(
    DateTime asOf,
  );

  Future<Result<RecurringTransactionModel, Failure>> getRecurringById(String id);
  Future<Result<void, Failure>> createRecurring(RecurringTransactionModel model);
  Future<Result<void, Failure>> updateRecurring(RecurringTransactionModel model);
  Future<Result<void, Failure>> deleteRecurring(String id);
}
