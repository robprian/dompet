import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/core/utils/datetime_utils.dart';
import 'package:dompet/core/utils/logger.dart';
import 'package:dompet/core/utils/number_format_provider.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:dompet/features/transactions/presentation/widgets/forms/transaction_form_sheet.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dialogs/dompet_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'goal_detail_notifier.g.dart';

/// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).
@riverpod
Stream<List<TransactionModel>> goalTransactions(Ref ref, GoalModel goal) {
  return ref
      .read(transactionRepositoryProvider)
      .watchTransactions(
        accountIds: {goal.accountId},
      )
      .asyncMap((result) {
        return switch (result) {
          Success(value: final transactions) => transactions,
          ErrorResult(error: final failure) => Future.error(failure, StackTrace.current),
        };
      });
}

/// A single contribution (or withdrawal) movement for a goal, derived from its
/// linked pocket transfers. Not a regular expense: money is only reallocated.
class GoalContribution {
  /// Creates a [GoalContribution].
  const GoalContribution({
    required this.transaction,
    required this.amount,
    required this.isIncoming,
    required this.occurredAt,
    required this.counterpartyName,
  });

  /// Underlying ledger transaction.
  final TransactionModel transaction;

  /// Positive movement amount.
  final int amount;

  /// True when funds moved into the goal pocket (contribution).
  final bool isIncoming;

  /// When the movement happened.
  final DateTime occurredAt;

  /// Display name of the source (incoming) or destination (outgoing) account.
  final String counterpartyName;
}

/// Watches goal contributions derived from transfers touching the linked
/// pocket. These are allocations, so they are never counted as expenses.
@riverpod
Stream<List<GoalContribution>> goalContributions(Ref ref, GoalModel goal) {
  final accounts = ref.watch(accountsStreamProvider).value ?? const <AccountModel>[];
  final byId = {for (final account in accounts) account.id: account};

  return ref
      .read(transactionRepositoryProvider)
      .watchTransactions(
        accountIds: {goal.accountId},
        types: {TransactionType.transfer},
      )
      .asyncMap((result) {
        return switch (result) {
          Success(value: final transactions) => transactions.map((transaction) {
            final isIncoming = transaction.destinationAccountId == goal.accountId;
            final counterpartyId = isIncoming ? transaction.accountId : transaction.destinationAccountId;
            return GoalContribution(
              transaction: transaction,
              amount: transaction.amount,
              isIncoming: isIncoming,
              occurredAt: transaction.transactionDate,
              counterpartyName: (counterpartyId != null ? byId[counterpartyId]?.name : null) ?? '',
            );
          }).toList()..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
          ErrorResult(error: final failure) => Future.error(failure, StackTrace.current),
        };
      });
}

/// Notifier coordinating goal detail actions such as deletion and goal fulfillment.
@Riverpod(keepAlive: true)
class GoalDetailNotifier extends _$GoalDetailNotifier {
  @override
  void build() {
    // Intentionally left blank as this notifier primarily provides methods
  }

  /// Adds savings to [goal] by transferring [amount] from the [source] account
  /// into the goal's linked pocket. This is an allocation, never an expense.
  Future<Result<void, Failure>> contribute({
    required GoalModel goal,
    required AccountModel source,
    required int amount,
  }) async {
    final validation = _validateContribution(goal: goal, source: source, amount: amount);
    if (validation != null) return ErrorResult(validation);

    final now = DateTimeUtils.nowUtc();
    final transactionId = const Uuid().v7();
    final transaction = TransactionModel(
      id: transactionId,
      accountId: source.id,
      destinationAccountId: goal.accountId,
      type: TransactionType.transfer,
      amount: amount,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
      note: t.goals.contributionNote(goal: goal.name),
      items: [
        TransactionItemModel(
          id: const Uuid().v7(),
          transactionId: transactionId,
          amount: amount,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final result = await ref.read(transactionRepositoryProvider).createTransaction(transaction);
    switch (result) {
      case Success():
        await _refreshGoals();
        return const Success(null);
      case ErrorResult(error: final failure):
        talker.error('Goal contribution failed', failure);
        return ErrorResult(failure);
    }
  }

  /// Withdraws [amount] from [goal]'s linked pocket back into the [destination] account.
  Future<Result<void, Failure>> withdraw({
    required GoalModel goal,
    required AccountModel destination,
    required int amount,
  }) async {
    if (amount <= 0) {
      return ErrorResult(ValidationFailure(t.goals.targetAmountGreaterThanZero));
    }

    final now = DateTimeUtils.nowUtc();
    final transactionId = const Uuid().v7();
    final transaction = TransactionModel(
      id: transactionId,
      accountId: goal.accountId,
      destinationAccountId: destination.id,
      type: TransactionType.transfer,
      amount: amount,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
      note: t.goals.withdrawalNote(goal: goal.name),
      items: [
        TransactionItemModel(
          id: const Uuid().v7(),
          transactionId: transactionId,
          amount: amount,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final result = await ref.read(transactionRepositoryProvider).createTransaction(transaction);
    switch (result) {
      case Success():
        await _refreshGoals();
        return const Success(null);
      case ErrorResult(error: final failure):
        talker.error('Goal withdrawal failed', failure);
        return ErrorResult(failure);
    }
  }

  ValidationFailure? _validateContribution({
    required GoalModel goal,
    required AccountModel source,
    required int amount,
  }) {
    if (amount <= 0) {
      return ValidationFailure(t.goals.targetAmountGreaterThanZero);
    }
    if (source.id == goal.accountId) {
      return ValidationFailure(t.goals.selectSourceAccount);
    }
    if (amount > source.balance) {
      final settings = ref.read(settingsProvider);
      final symbol = settings.settings?.baseCurrency?.symbol ?? '';
      final precision = settings.settings?.baseCurrency?.precision ?? 0;
      final formattedBalance = ref
          .read(numberFormatServiceProvider)
          .formatCurrency(source.balance, symbol: symbol, precision: precision);
      return ValidationFailure(t.goals.insufficientBalance(account: source.name, balance: formattedBalance));
    }
    return null;
  }

  Future<void> _refreshGoals() async {
    ref
      ..invalidate(goalProvider)
      ..invalidate(goalListStatesProvider);
  }

  /// Verifies the pocket has zero balance before prompting deletion confirmation.
  Future<bool> deleteGoal(BuildContext context, GoalModel goal, {required int currentBalance}) async {
    // Protect funds: forbid deleting a goal pocket if it still contains positive balance
    if (currentBalance > 0) {
      if (context.mounted) {
        await showDompetConfirmDialog(
          context,
          title: t.goals.actionDenied,
          body: t.goals.emptyBalanceBeforeDelete,
          confirmText: t.goals.ok,
        );
      }
      return false;
    }

    if (!context.mounted) return false;

    final confirm = await showDompetConfirmDialog(
      context,
      title: t.goals.deleteGoal,
      body: t
          .goals
          .areYouSureYouWantToDeleteThisGoalTheAssociatedPocketAccountAndItsHistoryWillAlsoBeRemovedThisActionCannotBeUndone,
      confirmText: t.goals.delete,
    );

    if (confirm == true) {
      await ref.read(goalProvider.notifier).deleteGoal(goal.id);
      return true;
    }
    return false;
  }

  /// Opens the expense transaction form to spend the saved goal amount and marks the goal as completed.
  Future<bool> fulfillGoal(BuildContext context, GoalModel goal) async {
    // Fulfill savings goal by spending the target balance as an expense from the goal pocket and marking goal completed
    final saved = await TransactionFormSheet.show(
      context,
      initialType: TransactionType.expense,
      initialAccountId: goal.accountId,
      initialAmount: goal.targetAmount.toString(),
      initialNote: 'Fulfill Goal: ${goal.name}',
    );

    if (saved == true) {
      final updatedGoal = goal.copyWith(status: GoalStatus.completed);
      await ref.read(goalProvider.notifier).updateGoal(updatedGoal);
      return true;
    }
    return false;
  }
}
