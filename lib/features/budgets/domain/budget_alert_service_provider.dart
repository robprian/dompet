import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/features/budgets/domain/budget_alert_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_alert_service_provider.g.dart';

/// Provides a singleton instance of [BudgetAlertService] injected with the budget repository.
@riverpod
BudgetAlertService budgetAlertService(Ref ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return BudgetAlertService(budgetRepository: repo);
}
