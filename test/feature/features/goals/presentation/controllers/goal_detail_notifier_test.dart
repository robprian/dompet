import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/failure.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/features/accounts/data/account_repository_impl.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_detail_notifier.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/transactions/data/transaction_repository_impl.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';

class _FakeGoalNotifier extends GoalNotifier {
  bool deleteCalled = false;
  bool updateCalled = false;
  GoalModel? updatedGoal;

  @override
  Stream<List<GoalModel>> build() => const Stream.empty();

  @override
  Future<void> deleteGoal(String id) async {
    deleteCalled = true;
  }

  @override
  Future<void> updateGoal(GoalModel model) async {
    updateCalled = true;
    updatedGoal = model;
  }
}

void main() {
  Widget wrap(Widget child, ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          builder: (context, child) => FTheme(
            data: lightTheme,
            child: child!,
          ),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('GoalDetailNotifier', () {
    late ProviderContainer container;
    late _FakeGoalNotifier fakeGoalNotifier;

    final dummyGoal = GoalModel(
      id: 'g1',
      accountId: 'a1',
      name: 'Test',
      targetAmount: 100,
      status: GoalStatus.active,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

    setUp(() {
      fakeGoalNotifier = _FakeGoalNotifier();
      container = ProviderContainer(
        overrides: [
          goalProvider.overrideWith(() => fakeGoalNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('deleteGoal confirmation true', (tester) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  container.read(goalDetailProvider.notifier).deleteGoal(context, dummyGoal, currentBalance: 0);
                },
                child: const Text('Delete'),
              );
            },
          ),
          container,
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap delete on confirm dialog
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(fakeGoalNotifier.deleteCalled, isTrue);
    });

    testWidgets('deleteGoal confirmation false', (tester) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  container.read(goalDetailProvider.notifier).deleteGoal(context, dummyGoal, currentBalance: 0);
                },
                child: const Text('Delete'),
              );
            },
          ),
          container,
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap cancel on confirm dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fakeGoalNotifier.deleteCalled, isFalse);
    });

    test('goalTransactions provider success', () async {
      final fakeTxRepo = _FakeTransactionRepo();
      final c = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith((ref) => fakeTxRepo),
        ],
      );
      addTearDown(c.dispose);

      final sub = c.listen(goalTransactionsProvider(dummyGoal), (_, __) {});
      final res = await c.read(goalTransactionsProvider(dummyGoal).future);
      sub.close();
      expect(res, isEmpty);
    });

    test('goalContributions classifies incoming, outgoing, and derives names', () async {
      final now = DateTime.now().toUtc();
      TransactionModel transfer(String id, String from, String? to, String note) => TransactionModel(
        id: id,
        accountId: from,
        destinationAccountId: to,
        type: TransactionType.transfer,
        amount: 500,
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
        note: note,
        items: const [],
      );
      final fakeTxRepo = _FakeTransactionRepo(
        transfers: [
          transfer('t-in', 'wallet', 'a1', 'Contribution · Test'),
          transfer('t-out', 'a1', 'wallet', 'Withdrawal · Test'),
        ],
      );
      final c = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith((ref) => fakeTxRepo),
          accountsStreamProvider.overrideWith((ref) => Stream.value([_account('wallet', 'Wallet')])),
        ],
      );
      addTearDown(c.dispose);

      final sub = c.listen(goalContributionsProvider(dummyGoal), (_, __) {});
      final res = await c.read(goalContributionsProvider(dummyGoal).future);
      sub.close();
      expect(res, hasLength(2));
      expect(
        res.where((r) => r.isIncoming),
        hasLength(1),
      );
      expect(res.firstWhere((r) => r.isIncoming).counterpartyName, 'Wallet');
      expect(res.firstWhere((r) => !r.isIncoming).counterpartyName, 'Wallet');
    });
  });
}

AccountModel _account(String id, String name) => AccountModel(
  id: id,
  name: name,
  type: AccountType.assets,
  balance: 1000,
  isActive: true,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _FakeTransactionRepo implements ITransactionRepository {
  _FakeTransactionRepo({this.transfers = const []});

  final List<TransactionModel> transfers;

  @override
  Stream<Result<List<TransactionModel>, Failure>> watchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? categoryId,
    String? goalId,
    Set<String>? categoryIds,
    Set<String>? accountIds,
    Set<TransactionType>? types,
    Set<String>? debtIds,
    Set<String>? recurringIds,
    int? limit,
  }) {
    if (types?.length == 1 && types!.contains(TransactionType.transfer)) {
      return Stream.value(Success(transfers));
    }
    return Stream.value(const Success(<TransactionModel>[]));
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
