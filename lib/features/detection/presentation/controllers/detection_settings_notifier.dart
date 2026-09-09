import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/features/detection/domain/services/detection_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detection_settings_notifier.g.dart';

/// Persisted detection preferences surfaced to the settings UI.
class DetectionSettingsState {

  /// Creates a detection settings state.
  const DetectionSettingsState({
    this.enabled = true,
    this.autoImportEnabled = true,
    this.autoImportThreshold = 0.9,
    this.salaryDetectionEnabled = true,
    this.isLoading = true,
    this.accessEnabled = false,
  });
  /// Loads the state from stored values and the platform.
  factory DetectionSettingsState.load({
    required Map<String, String?> raw,
    required bool accessEnabled,
  }) {
    final policy = DetectionPolicy.fromSettings(raw);
    return DetectionSettingsState(
      enabled: policy.enabled,
      autoImportEnabled: policy.autoImportEnabled,
      autoImportThreshold: policy.autoImportThreshold,
      salaryDetectionEnabled: policy.salaryDetectionEnabled,
      isLoading: false,
      accessEnabled: accessEnabled,
    );
  }

  /// Master switch.
  final bool enabled;

  /// Automatic import of high-confidence candidates.
  final bool autoImportEnabled;

  /// Confidence required for auto-import.
  final double autoImportThreshold;

  /// Salary detection switch.
  final bool salaryDetectionEnabled;

  /// Whether the settings are still loading.
  final bool isLoading;

  /// Whether Android notification access is granted.
  final bool accessEnabled;
}

/// Manages detection preferences and platform access state.
@riverpod
class DetectionSettingsNotifier extends _$DetectionSettingsNotifier {
  @override
  Future<DetectionSettingsState> build() async {
    final repo = ref.watch(detectionRepositoryProvider);
    final service = ref.watch(detectionNotificationServiceProvider);
    final raw = <String, String?>{
      'detectionEnabled': await repo.getSetting('detectionEnabled'),
      'detectionAutoImportEnabled': await repo.getSetting('detectionAutoImportEnabled'),
      'detectionAutoImportThreshold': await repo.getSetting('detectionAutoImportThreshold'),
      'salaryDetectionEnabled': await repo.getSetting('salaryDetectionEnabled'),
    };
    final access = await service.isNotificationAccessEnabled();
    return DetectionSettingsState.load(raw: raw, accessEnabled: access);
  }

  Future<void> _write(String key, String value) async {
    final repo = ref.read(detectionRepositoryProvider);
    await repo.setSetting(key, value);
    ref.invalidateSelf();
  }

  /// Toggles the master detection switch.
  Future<void> setEnabled({required bool value}) => _write('detectionEnabled', '$value');

  /// Toggles automatic import.
  Future<void> setAutoImportEnabled({required bool value}) => _write('detectionAutoImportEnabled', '$value');

  /// Sets the auto-import confidence threshold.
  Future<void> setAutoImportThreshold({required double value}) => _write('detectionAutoImportThreshold', '$value');

  /// Toggles salary detection.
  Future<void> setSalaryDetectionEnabled({required bool value}) => _write('salaryDetectionEnabled', '$value');

  /// Opens the Android notification access settings.
  Future<void> requestNotificationAccess() async {
    final service = ref.read(detectionNotificationServiceProvider);
    await service.requestNotificationAccess();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    ref.invalidateSelf();
  }

  /// Re-checks platform access state.
  Future<void> refreshAccess() async {
    ref.invalidateSelf();
  }
}
