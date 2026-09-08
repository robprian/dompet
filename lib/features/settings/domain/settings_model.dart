import 'package:dompet/features/settings/domain/currency_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
abstract class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    required String themeMode, // 'system', 'light', 'dark'
    @Default('system') String language,
    @Default('system') String numberFormat,
    CurrencyModel? baseCurrency,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);
}
