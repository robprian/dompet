import 'package:dompet/core/logger/dompet_logger.dart';
import 'package:dompet/features/settings/data/settings_repository.dart';
import 'package:dompet/features/settings/domain/currency_model.dart';
import 'package:dompet/features/settings/domain/settings_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

/// Immutable UI state encapsulating current application settings and loading status.
class SettingsState {
  /// Creates a [SettingsState].
  const SettingsState({
    this.settings,
    this.isLoading = false,
    this.error,
  });

  /// Active settings model or `null` while loading.
  final SettingsModel? settings;

  /// Whether settings are currently being loaded or updated.
  final bool isLoading;

  /// Error message on failure.
  final String? error;

  /// Creates a copy of this state with specified fields updated.
  SettingsState copyWith({
    SettingsModel? settings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Notifier coordinating user preferences (theme, language, number format, base currency).
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  bool _disposed = false;

  @override
  SettingsState build() {
    ref.onDispose(() {
      _disposed = true;
    });
    Future.microtask(_loadSettings);
    return const SettingsState(isLoading: true);
  }

  Future<void> _loadSettings() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      final settings = await repo.getSettings();
      if (_disposed) return;
      state = SettingsState(settings: settings);
    } on Exception catch (e, stackTrace) {
      talker.error('Settings load failed', e, stackTrace);
      if (_disposed) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> retryLoading() async {
    if (_disposed || state.isLoading) return;
    await _loadSettings();
  }

  /// Updates and reloads the active application theme mode.
  Future<void> setThemeMode(String mode) async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setThemeMode(mode);
      await _loadSettings();
    } on Exception catch (_) {
      // Handle error
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setLanguage(language);
      await _loadSettings();
    } on Exception catch (_) {
      // Handle error
    }
  }

  Future<void> setNumberFormat(String numberFormat) async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setNumberFormat(numberFormat);
      await _loadSettings();
    } on Exception catch (_) {
      // Handle error
    }
  }

  Future<bool> setBaseCurrency(String currencyId) async {
    if (_disposed || state.isLoading || state.settings == null || currencyId.isEmpty) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setBaseCurrency(currencyId);
      final settings = await repo.getSettings();
      if (_disposed) return false;
      if (settings.baseCurrency?.id != currencyId) {
        state = state.copyWith(isLoading: false, error: 'Currency persistence could not be confirmed');
        return false;
      }
      state = SettingsState(settings: settings);
      return true;
    } on Exception catch (e, stackTrace) {
      talker.error('Base currency save failed', e, stackTrace);
      if (!_disposed) state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<List<CurrencyModel>> getAvailableCurrencies() async {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.getCurrencies();
  }
}
