import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/budgets/domain/budget_model.dart';

abstract class IBudgetRepository {
  Future<Result<List<BudgetModel>, Failure>> getBudgets();
  Future<Result<BudgetModel, Failure>> getBudgetById(String id);
  Future<Result<void, Failure>> createBudget(BudgetModel model);
  Future<Result<void, Failure>> updateBudget(BudgetModel model);
  Future<Result<void, Failure>> deleteBudget(String id);
  Future<Result<int, Failure>> getSpentAmountForBudget({
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
    String? accountId,
  });
}
