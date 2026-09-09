// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_review_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams candidates awaiting review.

@ProviderFor(pendingDetections)
final pendingDetectionsProvider = PendingDetectionsProvider._();

/// Streams candidates awaiting review.

final class PendingDetectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionDetectionModel>>,
          List<TransactionDetectionModel>,
          Stream<List<TransactionDetectionModel>>
        >
    with
        $FutureModifier<List<TransactionDetectionModel>>,
        $StreamProvider<List<TransactionDetectionModel>> {
  /// Streams candidates awaiting review.
  PendingDetectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDetectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDetectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionDetectionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionDetectionModel>> create(Ref ref) {
    return pendingDetections(ref);
  }
}

String _$pendingDetectionsHash() => r'862469533dbb48aacbb21aac2ed1aba68b3e84b2';

/// Counts candidates awaiting review.

@ProviderFor(pendingDetectionCount)
final pendingDetectionCountProvider = PendingDetectionCountProvider._();

/// Counts candidates awaiting review.

final class PendingDetectionCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Counts candidates awaiting review.
  PendingDetectionCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDetectionCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDetectionCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return pendingDetectionCount(ref);
  }
}

String _$pendingDetectionCountHash() =>
    r'e9d0576caf46715564c05adc4fd5b615ba5639d3';

/// Handles saving or ignoring reviewed detection candidates.

@ProviderFor(DetectionReviewNotifier)
final detectionReviewProvider = DetectionReviewNotifierProvider._();

/// Handles saving or ignoring reviewed detection candidates.
final class DetectionReviewNotifierProvider
    extends $AsyncNotifierProvider<DetectionReviewNotifier, void> {
  /// Handles saving or ignoring reviewed detection candidates.
  DetectionReviewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detectionReviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detectionReviewNotifierHash();

  @$internal
  @override
  DetectionReviewNotifier create() => DetectionReviewNotifier();
}

String _$detectionReviewNotifierHash() =>
    r'5f525922a93e224ebf64d44f18a9b2af282fc3fd';

/// Handles saving or ignoring reviewed detection candidates.

abstract class _$DetectionReviewNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
