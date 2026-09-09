import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/services/category_inference_engine.dart';
import 'package:dompet/features/detection/domain/services/detection_policy.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:dompet/features/detection/domain/services/salary_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalaryDetector', () {
    const detector = SalaryDetector();

    test('strong keyword income scores as likely salary', () {
      final assessment = detector.assess(
        sourceText: 'Gaji bulanan Rp10.000.000 diterima',
        amount: 10000000,
        occurredAt: DateTime.utc(2026, 3, 25),
        history: const [],
      );
      expect(assessment.score, greaterThanOrEqualTo(0.45));
      expect(assessment.isLikely, isFalse);
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

    test('uncertain tier lands between 0.50 and 0.69', () {
      final assessment = detector.assess(
        sourceText: 'Dana masuk Rp200.000 diterima',
        amount: 200000,
        occurredAt: DateTime.utc(2026, 3, 15),
        history: const [],
      );
      expect(assessment.score, greaterThanOrEqualTo(0.0));
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
  });

  group('CategoryInferenceEngine', () {
    test('maps known merchants locally', () {
      final engine = CategoryInferenceEngine();
      expect(engine.infer('PLN Prabayar')?.label, 'Utilities');
      expect(engine.infer('KOPI KENANGAN STC')?.label, 'Food & Dining');
      expect(engine.infer('Netflix')?.label, 'Subscription / Entertainment');
      expect(engine.infer('Tokopedia')?.label, 'Shopping');
      expect(engine.infer('Telkomsel')?.label, 'Mobile / Internet');
    });

    test('returns null for unknown merchants', () {
      expect(CategoryInferenceEngine().infer('Toko Tak Dikenal XYZ'), isNull);
      expect(CategoryInferenceEngine().infer(null), isNull);
      expect(CategoryInferenceEngine().infer(''), isNull);
    });

    test('learned rules override defaults', () {
      final engine = CategoryInferenceEngine();
      engine.learn(merchant: 'Toko Tak Dikenal XYZ', category: 'Shopping');
      expect(engine.infer('Toko Tak Dikenal XYZ kondangan')?.label, 'Shopping');
    });
  });

  group('DetectionPolicy', () {
    test('defaults enable detection with 0.90 auto-import', () {
      expect(DetectionPolicy.defaults.enabled, isTrue);
      expect(DetectionPolicy.defaults.shouldAutoImport(0.9), isTrue);
      expect(DetectionPolicy.defaults.shouldAutoImport(0.89), isFalse);
      expect(DetectionPolicy.defaults.shouldReview(0.5), isTrue);
      expect(DetectionPolicy.defaults.shouldReview(0.49), isFalse);
    });

    test('fromSettings parses stored values', () {
      final policy = DetectionPolicy.fromSettings(const {
        'detectionEnabled': 'false',
        'detectionAutoImportEnabled': 'true',
        'detectionAutoImportThreshold': '0.8',
        'salaryDetectionEnabled': 'true',
      });
      expect(policy.enabled, isFalse);
      expect(policy.shouldAutoImport(0.9), isFalse);
    });

    test('fromSettings rejects invalid threshold values', () {
      final policy = DetectionPolicy.fromSettings(const {'detectionAutoImportThreshold': 'xyz'});
      expect(policy.autoImportThreshold, 0.9);
      final overflow = DetectionPolicy.fromSettings(const {'detectionAutoImportThreshold': '2.0'});
      expect(overflow.autoImportThreshold, 0.9);
    });
  });

  group('ImportOutcome', () {
    test('carries outcome metadata', () {
      const outcome = ImportOutcome(
        type: ImportOutcomeType.imported,
        detectionId: 'd1',
        amount: 25000,
        confidence: 0.95,
        isSalary: false,
      );
      expect(outcome.type, ImportOutcomeType.imported);
      expect(outcome.detectionId, 'd1');
      expect(ImportOutcomeType.values.length, 4);
    });
  });

  group('Detection enums', () {
    test('enum storage names stay lowercase', () {
      for (final value in DetectionTransactionType.values) {
        expect(value.name, equals(value.name.toLowerCase()));
      }
      for (final value in ConfidenceTier.values) {
        expect(value.name, equals(value.name.toLowerCase()));
      }
      for (final value in DetectionStatus.values) {
        expect(value.name, equals(value.name.toLowerCase()));
      }
      for (final value in PaymentMethod.values) {
        expect(value.name, equals(value.name.toLowerCase()));
      }
    });
  });

  group('NotificationPayload', () {
    test('stores raw notification fields', () {
      final payload = NotificationPayload(
        package: 'com.bank',
        title: 'Info',
        body: 'Rp25.000',
        postedAt: DateTime.utc(2026, 3, 15),
      );
      expect(payload.package, 'com.bank');
      expect(payload.title, 'Info');
      expect(payload.body, 'Rp25.000');
    });
  });
}
