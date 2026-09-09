import 'package:freezed_annotation/freezed_annotation.dart';

part 'allocation_engine.freezed.dart';

/// Configurable bucket ratios for the salary allocation plan.
@freezed
abstract class AllocationConfig with _$AllocationConfig {
  const factory AllocationConfig({
    @Default(50) int needsPercent,
    @Default(20) int savingsPercent,
    @Default(15) int debtPercent,
    @Default(10) int lifestylePercent,
    @Default(5) int bufferPercent,
  }) = _AllocationConfig;

  const AllocationConfig._();

  /// Parses a persisted "50|20|15|10|5" value; falls back to defaults.
  factory AllocationConfig.fromEncoded(String? encoded) {
    if (encoded == null) return const AllocationConfig();
    final parts = encoded.split('|');
    if (parts.length != 5) return const AllocationConfig();
    final values = parts.map(int.tryParse).toList();
    if (values.any((v) => v == null || v < 0)) return const AllocationConfig();
    final nums = values.cast<int>();
    return AllocationConfig(
      needsPercent: nums[0],
      savingsPercent: nums[1],
      debtPercent: nums[2],
      lifestylePercent: nums[3],
      bufferPercent: nums[4],
    );
  }

  /// Encodes to the persisted "50|20|15|10|5" format.
  String encode() => [needsPercent, savingsPercent, debtPercent, lifestylePercent, bufferPercent].join('|');
}

/// Result of allocating income across local budget buckets.
@freezed
abstract class AllocationPlanModel with _$AllocationPlanModel {
  const factory AllocationPlanModel({
    required int income,
    required int needs,
    required int savings,
    required int debt,
    required int lifestyle,
    required int buffer,
  }) = _AllocationPlanModel;

  const AllocationPlanModel._();

  /// Sum of the five buckets.
  int get total => needs + savings + debt + lifestyle + buffer;
}

/// Pure engine computing proportional allocation plans from a config.
class AllocationEngine {
  /// Creates the engine.
  AllocationEngine({AllocationConfig? config}) : _config = config ?? const AllocationConfig();

  final AllocationConfig _config;

  /// Allocates [income] across the configured bucket ratios.
  AllocationPlanModel allocate(int income) {
    if (income <= 0) {
      return const AllocationPlanModel(income: 0, needs: 0, savings: 0, debt: 0, lifestyle: 0, buffer: 0);
    }
    int ratio(int percent) => income * percent ~/ 100;
    return AllocationPlanModel(
      income: income,
      needs: ratio(_config.needsPercent),
      savings: ratio(_config.savingsPercent),
      debt: ratio(_config.debtPercent),
      lifestyle: ratio(_config.lifestylePercent),
      buffer: ratio(_config.bufferPercent),
    );
  }
}
