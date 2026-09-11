import 'package:dompet/core/utils/number_format_service.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:riverpod/riverpod.dart';

/// Exposes a [NumberFormatService] bound to the user's number-format setting.
///
/// Widgets should watch this provider instead of reading
/// `settings.numberFormat` and constructing formats themselves, so every
/// amount across the app uses the same locale separators.
final numberFormatServiceProvider = Provider<NumberFormatService>((ref) {
  final numberFormat =
      ref.watch(settingsProvider.select((state) => state.settings?.numberFormat)) ??
      NumberFormatService.systemLocale;
  return NumberFormatService(numberFormat);
});
