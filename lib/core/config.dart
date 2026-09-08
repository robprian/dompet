// coverage:ignore-file
/// Global configuration for the application environment.
///
/// Contains static constants that read from compile-time environment variables
/// (e.g. via `--dart-define-from-file=.env`).
class AppConfig {
  AppConfig._();

  /// Whether to seed essential initial data (like default categories/pockets) on first run.
  ///
  /// Set via `DOMPET_SEED_ESSENTIALS`. Defaults to `true`.
  static const bool seedEssentials = bool.fromEnvironment(
    'DOMPET_SEED_ESSENTIALS',
    defaultValue: true,
  );

  /// Whether to seed dummy data for testing purposes.
  ///
  /// Set via `DOMPET_SEED_DUMMY_DATA`. Defaults to `false`.
  static const bool seedDummyData = bool.fromEnvironment(
    'DOMPET_SEED_DUMMY_DATA',
  );
}
