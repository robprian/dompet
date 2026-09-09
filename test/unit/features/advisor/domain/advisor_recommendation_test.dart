import 'package:dompet/features/advisor/domain/advisor_enums.dart';
import 'package:dompet/features/advisor/domain/advisor_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdvisorRecommendationModel', () {
    test('stores structured recommendation data', () {
      const recommendation = AdvisorRecommendationModel(
        id: 'r1',
        type: AdvisorRecommendationType.budget,
        severity: AdvisorSeverity.warning,
        amount: 200000,
        ratio: 1.2,
        relatedName: 'Makan',
      );
      expect(recommendation.type, AdvisorRecommendationType.budget);
      expect(recommendation.severity, AdvisorSeverity.warning);
      expect(recommendation.amount, 200000);
      expect(recommendation.ratio, 1.2);
      expect(recommendation.relatedName, 'Makan');
      expect(recommendation.isSalaryRelated, isFalse);
    });

    test('supports copyWith', () {
      const recommendation = AdvisorRecommendationModel(
        id: 'r1',
        type: AdvisorRecommendationType.salaryAllocation,
        severity: AdvisorSeverity.info,
        isSalaryRelated: true,
      );
      final updated = recommendation.copyWith(amount: 10000000);
      expect(updated.amount, 10000000);
      expect(updated.isSalaryRelated, isTrue);
    });
  });

  group('Advisor enums', () {
    test('covers every domain event', () {
      expect(
        AdvisorEventType.values,
        containsAll([
          AdvisorEventType.transactionCreated,
          AdvisorEventType.incomeDetected,
          AdvisorEventType.salaryDetected,
          AdvisorEventType.budgetThresholdReached,
          AdvisorEventType.largeTransactionDetected,
          AdvisorEventType.unusualSpendingDetected,
          AdvisorEventType.recurringExpenseDetected,
        ]),
      );
    });
  });
}
