import 'package:dompet/features/detection/domain/services/salary_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalaryDetector', () {
    const detector = SalaryDetector();

    test('strong keyword income scores below auto-classify without history', () {
      final assessment = detector.assess(
        sourceText: 'Gaji bulanan Rp10.000.000 diterima',
        amount: 10000000,
        occurredAt: DateTime.utc(2026, 3, 25),
        history: const [],
      );
      expect(assessment.score, greaterThanOrEqualTo(0.45));
      expect(assessment.isLikely, isFalse);
      expect(assessment.isHighConfidence, isFalse);
    });

    test('recurring amount history lifts a keyword hit to high confidence', () {
      final assessment = detector.assess(
        sourceText: 'Gaji Rp10.000.000 diterima',
        amount: 10000000,
        occurredAt: DateTime.utc(2026, 3, 25),
        history: [
          SalaryObservation(amount: 10000000, occurredAt: DateTime.utc(2026, 2, 25)),
          SalaryObservation(amount: 10000000, occurredAt: DateTime.utc(2026, 1, 25)),
        ],
      );
      expect(assessment.score, greaterThanOrEqualTo(0.9));
      expect(assessment.isHighConfidence, isTrue);
    });

    test('ordinary income without keywords scores low', () {
      final assessment = detector.assess(
        sourceText: 'Dana terkirim Rp50.000 ke SITI',
        amount: 50000,
        occurredAt: DateTime.utc(2026, 3, 15),
        history: const [],
      );
      expect(assessment.score, lessThan(0.5));
      expect(assessment.isLikely, isFalse);
    });

    test('weak keyword income stays below the review bar', () {
      final assessment = detector.assess(
        sourceText: 'Dana masuk Rp200.000 diterima',
        amount: 200000,
        occurredAt: DateTime.utc(2026, 3, 15),
        history: const [],
      );
      expect(assessment.score, lessThan(0.5));
    });

    test('very low amounts never auto-classify as salary', () {
      final assessment = detector.assess(
        sourceText: 'Gaji Rp500 diterima',
        amount: 500,
        occurredAt: DateTime.utc(2026, 3, 15),
        history: const [],
      );
      expect(assessment.isHighConfidence, isFalse);
    });

    test('history outside the lookback window is ignored', () {
      final assessment = detector.assess(
        sourceText: 'Gaji Rp10.000.000 diterima',
        amount: 10000000,
        occurredAt: DateTime.utc(2026, 3, 25),
        history: [
          SalaryObservation(amount: 10000000, occurredAt: DateTime.utc(2025, 6, 25)),
        ],
      );
      expect(assessment.isHighConfidence, isFalse);
    });
  });
}
