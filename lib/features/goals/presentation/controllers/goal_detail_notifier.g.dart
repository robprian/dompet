// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).

@ProviderFor(goalTransactions)
final goalTransactionsProvider = GoalTransactionsFamily._();

/// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).

final class GoalTransactionsProvider
    extends
        $FunctionalProvider<AsyncValue<List<TransactionModel>>, List<TransactionModel>, Stream<List<TransactionModel>>>
    with $FutureModifier<List<TransactionModel>>, $StreamProvider<List<TransactionModel>> {
  /// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).
  GoalTransactionsProvider._({
    required GoalTransactionsFamily super.from,
    required GoalModel super.argument,
  }) : super(
         retry: null,
         name: r'goalTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalTransactionsHash();

  @override
  String toString() {
    return r'goalTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionModel>> create(Ref ref) {
    final argument = this.argument as GoalModel;
    return goalTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalTransactionsHash() => r'c38f6d823473ece186f45bed0e924b0ccae31816';

/// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).

final class GoalTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionModel>>, GoalModel> {
  GoalTransactionsFamily._()
    : super(
        retry: null,
        name: r'goalTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches transactions associated with the goal's linked pocket account (contributions and withdrawals).

  GoalTransactionsProvider call(GoalModel goal) => GoalTransactionsProvider._(argument: goal, from: this);

  @override
  String toString() => r'goalTransactionsProvider';
}

/// Watches goal contributions derived from transfers touching the linked
/// pocket. These are allocations, so they are never counted as expenses.

@ProviderFor(goalContributions)
final goalContributionsProvider = GoalContributionsFamily._();

/// Watches goal contributions derived from transfers touching the linked
/// pocket. These are allocations, so they are never counted as expenses.

final class GoalContributionsProvider
    extends
        $FunctionalProvider<AsyncValue<List<GoalContribution>>, List<GoalContribution>, Stream<List<GoalContribution>>>
    with $FutureModifier<List<GoalContribution>>, $StreamProvider<List<GoalContribution>> {
  /// Watches goal contributions derived from transfers touching the linked
  /// pocket. These are allocations, so they are never counted as expenses.
  GoalContributionsProvider._({
    required GoalContributionsFamily super.from,
    required GoalModel super.argument,
  }) : super(
         retry: null,
         name: r'goalContributionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalContributionsHash();

  @override
  String toString() {
    return r'goalContributionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GoalContribution>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GoalContribution>> create(Ref ref) {
    final argument = this.argument as GoalModel;
    return goalContributions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalContributionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalContributionsHash() => r'041524c07801da342ddff4629fa800f32659e5c8';

/// Watches goal contributions derived from transfers touching the linked
/// pocket. These are allocations, so they are never counted as expenses.

final class GoalContributionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GoalContribution>>, GoalModel> {
  GoalContributionsFamily._()
    : super(
        retry: null,
        name: r'goalContributionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches goal contributions derived from transfers touching the linked
  /// pocket. These are allocations, so they are never counted as expenses.

  GoalContributionsProvider call(GoalModel goal) => GoalContributionsProvider._(argument: goal, from: this);

  @override
  String toString() => r'goalContributionsProvider';
}

/// Notifier coordinating goal detail actions such as deletion and goal fulfillment.

@ProviderFor(GoalDetailNotifier)
final goalDetailProvider = GoalDetailNotifierProvider._();

/// Notifier coordinating goal detail actions such as deletion and goal fulfillment.
final class GoalDetailNotifierProvider extends $NotifierProvider<GoalDetailNotifier, void> {
  /// Notifier coordinating goal detail actions such as deletion and goal fulfillment.
  GoalDetailNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalDetailProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalDetailNotifierHash();

  @$internal
  @override
  GoalDetailNotifier create() => GoalDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$goalDetailNotifierHash() => r'5d590a89c3dde272640d757b88d3f3a8ece2fbb5';

/// Notifier coordinating goal detail actions such as deletion and goal fulfillment.

abstract class _$GoalDetailNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
