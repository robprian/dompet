// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes offline financial recommendations reactively.

@ProviderFor(AdvisorNotifier)
final advisorProvider = AdvisorNotifierProvider._();

/// Computes offline financial recommendations reactively.
final class AdvisorNotifierProvider
    extends $NotifierProvider<AdvisorNotifier, AdvisorState> {
  /// Computes offline financial recommendations reactively.
  AdvisorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'advisorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$advisorNotifierHash();

  @$internal
  @override
  AdvisorNotifier create() => AdvisorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdvisorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdvisorState>(value),
    );
  }
}

String _$advisorNotifierHash() => r'510e27590ab6e6199da35c23874fbb75ee0ca4cd';

/// Computes offline financial recommendations reactively.

abstract class _$AdvisorNotifier extends $Notifier<AdvisorState> {
  AdvisorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdvisorState, AdvisorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdvisorState, AdvisorState>,
              AdvisorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
