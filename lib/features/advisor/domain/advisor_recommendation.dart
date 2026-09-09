import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'advisor_recommendation.freezed.dart';

/// Immutable, locally computed financial recommendation.
@freezed
abstract class AdvisorRecommendationModel with _$AdvisorRecommendationModel {
  const factory AdvisorRecommendationModel({
    required String id,
    required AdvisorRecommendationType type,
    required AdvisorSeverity severity,
    int? amount,
    double? ratio,
    String? relatedName,
    @Default(false) bool isSalaryRelated,
  }) = _AdvisorRecommendationModel;

  const AdvisorRecommendationModel._();
}
