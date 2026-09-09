// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages detection preferences and platform access state.

@ProviderFor(DetectionSettingsNotifier)
final detectionSettingsProvider = DetectionSettingsNotifierProvider._();

/// Manages detection preferences and platform access state.
final class DetectionSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          DetectionSettingsNotifier,
          DetectionSettingsState
        > {
  /// Manages detection preferences and platform access state.
  DetectionSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detectionSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detectionSettingsNotifierHash();

  @$internal
  @override
  DetectionSettingsNotifier create() => DetectionSettingsNotifier();
}

String _$detectionSettingsNotifierHash() =>
    r'd1170e5a6694e89bf0da2763d57620919f021459';

/// Manages detection preferences and platform access state.

abstract class _$DetectionSettingsNotifier
    extends $AsyncNotifier<DetectionSettingsState> {
  FutureOr<DetectionSettingsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DetectionSettingsState>, DetectionSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DetectionSettingsState>,
                DetectionSettingsState
              >,
              AsyncValue<DetectionSettingsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
