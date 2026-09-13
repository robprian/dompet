import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/dashboard/presentation/controllers/dashboard_notifier.dart';
import 'package:dompet/features/goals/domain/goal_model.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_detail_notifier.dart';
import 'package:dompet/features/goals/presentation/controllers/goal_notifier.dart';
import 'package:dompet/features/goals/presentation/screens/goal_detail_page.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:dompet/features/accounts/presentation/controllers/account_list_notifier.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/features/categories/domain/category_model.dart';

GoalModel _goal(
  String id,
  String name,
  int targetAmount, {
  String accountId = 'acc1',
  GoalStatus status = GoalStatus.active,
}) {
  return GoalModel(
    id: id,
    accountId: accountId,
    name: name,
    targetAmount: targetAmount,
    status: status,
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );
}

AccountModel _acc(String id, int balance) {
  return AccountModel(
    id: id,
    name: 'Wallet $id',
    type: AccountType.assets,
    balance: balance,
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );
}

class _FakeGoalNotifier extends GoalNotifier {
  _FakeGoalNotifier(this._goals);
  final List<GoalModel> _goals;
  @override
  Stream<List<GoalModel>> build() => Stream.value(_goals);
}

class _FakeDashboardNotifier extends DashboardNotifier {
  _FakeDashboardNotifier(this._state);
  final DashboardState _state;
  @override
  DashboardState build() => _state;
  @override
  Future<void> refresh() async {}
}

class _FakeAccountListNotifier extends AccountListNotifier {
  @override
  Stream<AccountListState> build() => Stream.value(const AccountListState(accounts: []));
}

class _FakeCategoryListNotifier extends CategoryListNotifier {
  @override
  Future<List<CategoryModel>> build() async => [];
}

class _FakeGoalDetailNotifier extends GoalDetailNotifier {
  bool deleted = false;

  @override
  Future<bool> deleteGoal(BuildContext context, GoalModel goal, {required int currentBalance}) async {
    deleted = true;
    return false; // Prevent actual navigation pop in test
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Widget wrapGoalDetail(
    String targetId,
    List<GoalModel> goals,
    DashboardState dashboardState, {
    List<TransactionModel>? txs,
    _FakeGoalDetailNotifier? mockNotifier,
  }) {
    final router = GoRouter(
      initialLocation: '/goal/$targetId',
      routes: [
        GoRoute(
          path: '/goal/:id',
          builder: (context, state) => GoalDetailPage(id: state.pathParameters['id']!),
        ),
      ],
    );

    final fakeGoalDetailNotifier = mockNotifier ?? _FakeGoalDetailNotifier();

    return ProviderScope(
      overrides: [
        goalProvider.overrideWith(() => _FakeGoalNotifier(goals)),
        dashboardProvider.overrideWith(() => _FakeDashboardNotifier(dashboardState)),
        goalTransactionsProvider.overrideWith((ref, goal) => Stream.value(txs ?? [])),
        goalContributionsProvider.overrideWith((ref, goal) => Stream.value(const [])),
        accountListProvider.overrideWith(() => _FakeAccountListNotifier()),
        categoryListProvider.overrideWith(() => _FakeCategoryListNotifier()),
        goalDetailProvider.overrideWith(() => fakeGoalDetailNotifier),
      ],
      child: TranslationProvider(
        child: FTheme(
          data: lightTheme,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      ),
    );
  }

  group('GoalDetailPage', () {
    testWidgets('shows loading if goal not found', (tester) async {
      await tester.pumpWidget(wrapGoalDetail('missing', [], const DashboardState()));
      await tester.pump();
      expect(find.byType(FCircularProgress), findsOneWidget);
    });

    testWidgets('displays goal details and savings CTA', (tester) async {
      final g = _goal('g1', 'Test Goal', 1000, accountId: 'a1');
      final dash = DashboardState(isLoading: false, accounts: [_acc('a1', 500)]);

      await tester.pumpWidget(wrapGoalDetail('g1', [g], dash));
      await tester.pumpAndSettle();

      expect(find.text('Test Goal'), findsOneWidget);
      expect(find.text('50% of target'), findsOneWidget);
      expect(find.text('SAVINGS HISTORY'), findsOneWidget);
      expect(find.text('Add Savings'), findsOneWidget);
      expect(find.text('No savings yet — add your first contribution.'), findsOneWidget);
    });

    testWidgets('shows Add Savings CTA for active goals', (tester) async {
      final g = _goal('g1', 'Funded Goal', 1000, accountId: 'a1');
      final dash = DashboardState(isLoading: false, accounts: [_acc('a1', 1000)]);

      await tester.pumpWidget(wrapGoalDetail('g1', [g], dash));
      await tester.pumpAndSettle();

      expect(find.text('Add Savings'), findsOneWidget);
    });

    testWidgets('hides Add Savings CTA for completed goals', (tester) async {
      final g = _goal('g1', 'Done Goal', 1000, accountId: 'a1', status: GoalStatus.completed);
      final dash = DashboardState(isLoading: false, accounts: [_acc('a1', 1000)]);

      await tester.pumpWidget(wrapGoalDetail('g1', [g], dash));
      await tester.pumpAndSettle();

      expect(find.text('Add Savings'), findsNothing);
    });

    testWidgets('tapping delete icon calls deleteGoal on notifier', (tester) async {
      final g = _goal('g1', 'Test Goal', 1000, accountId: 'a1');
      final dash = DashboardState(isLoading: false, accounts: [_acc('a1', 500)]);

      final mockGoalDetailNotifier = _FakeGoalDetailNotifier();
      await tester.pumpWidget(wrapGoalDetail('g1', [g], dash, mockNotifier: mockGoalDetailNotifier));
      await tester.pumpAndSettle();

      final trashFinder = find.byType(FHeaderAction).last;
      await tester.tap(trashFinder);
      await tester.pumpAndSettle();

      expect(mockGoalDetailNotifier.deleted, isTrue);
    });

    testWidgets('tapping Add Savings opens the contribution sheet', (tester) async {
      final g = _goal('g1', 'Test Goal', 1000, accountId: 'a1');
      final dash = DashboardState(isLoading: false, accounts: [_acc('a1', 1000), _acc('w2', 2000)]);

      await tester.pumpWidget(wrapGoalDetail('g1', [g], dash));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('goal-add-savings-button')));
      await tester.tap(find.byKey(const Key('goal-add-savings-button')));
      await tester.pumpAndSettle();

      expect(find.text('Add Savings to Test Goal'), findsOneWidget);
    });
  });
}
