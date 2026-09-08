import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';

abstract class IGoalRepository {
  Future<Result<List<GoalModel>, Failure>> getGoals();
  Stream<List<GoalModel>> watchGoals();
  Future<Result<GoalModel, Failure>> getGoalById(String id);
  Future<Result<void, Failure>> createGoal(GoalModel model);
  Future<Result<void, Failure>> updateGoal(GoalModel model);
  Future<Result<void, Failure>> deleteGoal(String id);
}
