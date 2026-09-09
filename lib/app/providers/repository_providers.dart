import 'package:dompet/core/data/drift_unit_of_work.dart';
import 'package:dompet/core/domain/i_unit_of_work.dart';
import 'package:dompet/database/database.dart';
import 'package:dompet/features/accounts/data/account_repository_impl.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/accounts/domain/i_account_repository.dart';
import 'package:dompet/features/budgets/data/budget_repository_impl.dart';
import 'package:dompet/features/budgets/domain/i_budget_repository.dart';
import 'package:dompet/features/categories/data/category_repository_impl.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/domain/i_category_repository.dart';
import 'package:dompet/features/debts/data/debt_repository_impl.dart';
import 'package:dompet/features/debts/domain/i_debt_repository.dart';
import 'package:dompet/features/detection/data/detection_notification_service.dart';
import 'package:dompet/features/detection/data/detection_repository.dart';
import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/i_detection_repository.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/goals/data/goal_repository_impl.dart';
import 'package:dompet/features/goals/domain/i_goal_repository.dart';
import 'package:dompet/features/recurring/data/recurring_repository_impl.dart';
import 'package:dompet/features/recurring/domain/i_recurring_repository.dart';
import 'package:dompet/features/transactions/data/transaction_repository_impl.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the singleton instance of the AppDatabase.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provides the [IUnitOfWork] implementation.
final unitOfWorkProvider = Provider<IUnitOfWork>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftUnitOfWork(db);
});

/// Provides the [IAccountRepository] implementation.
final accountRepositoryProvider = Provider<IAccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountRepositoryImpl(db.accountsDao);
});

/// Provides the [ITransactionRepository] implementation.
final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db.transactionsDao);
});

/// Provides the [ICategoryRepository] implementation.
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db.categoriesDao);
});

/// Provides the [IBudgetRepository] implementation.
final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db.budgetsDao);
});

/// Provides the [IGoalRepository] implementation.
final goalRepositoryProvider = Provider<IGoalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GoalRepositoryImpl(db.goalsDao);
});

/// Provides the [IDebtRepository] implementation.
final debtRepositoryProvider = Provider<IDebtRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DebtRepositoryImpl(db.debtsDao);
});

/// Provides the [IRecurringRepository] implementation.
final recurringRepositoryProvider = Provider<IRecurringRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringRepositoryImpl(db.recurringDao);
});

/// Provides the [IDetectionRepository] implementation.
final detectionRepositoryProvider = Provider<IDetectionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DetectionRepository(db.detectionDao, db);
});

/// Provides the local notification import pipeline.
final detectionImportServiceProvider = Provider<DetectionImportService>((ref) {
  return DetectionImportService(
    ref.watch(detectionRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

/// Provides the runtime bridge between Android notifications and the pipeline.
final detectionNotificationServiceProvider = Provider<DetectionNotificationService>((ref) {
  return DetectionNotificationService(
    bridge: NotificationBridge(),
    importService: ref.watch(detectionImportServiceProvider),
  );
});

// --- Stream Providers for Reactive UI ---

/// Reactive stream provider emitting updated lists of active [AccountModel] items.
final accountsStreamProvider = StreamProvider<List<AccountModel>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchAccounts().map((res) => res.fold((s) => s, (f) => []));
});

/// Reactive stream provider emitting updated lists of recent [TransactionModel] items.
final recentTransactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions().map((res) => res.fold((s) => s, (f) => []));
});

/// Reactive stream provider emitting updated lists of active [CategoryModel] items.
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories().map((res) => res.fold((s) => s, (f) => []));
});
