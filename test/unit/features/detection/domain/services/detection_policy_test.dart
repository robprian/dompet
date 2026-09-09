import 'package:dompet/features/detection/domain/services/detection_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetectionPolicy', () {
    test('defaults enable detection with 0.90 auto-import', () {
      expect(DetectionPolicy.defaults.enabled, isTrue);
      expect(DetectionPolicy.defaults.autoImportEnabled, isTrue);
      expect(DetectionPolicy.defaults.salaryDetectionEnabled, isTrue);
      expect(DetectionPolicy.defaults.shouldAutoImport(0.9), isTrue);
      expect(DetectionPolicy.defaults.shouldAutoImport(0.89), isFalse);
      expect(DetectionPolicy.defaults.shouldReview(0.5), isTrue);
      expect(DetectionPolicy.defaults.shouldReview(0.49), isFalse);
    });

    test('disabled policy never auto-imports', () {
      const policy = DetectionPolicy(
        enabled: false,
        autoImportEnabled: true,
        autoImportThreshold: 0.9,
        salaryDetectionEnabled: true,
      );
      expect(policy.shouldAutoImport(1.0), isFalse);
    });

    test('custom threshold controls auto-import', () {
      const policy = DetectionPolicy(
        enabled: true,
        autoImportEnabled: true,
        autoImportThreshold: 0.8,
        salaryDetectionEnabled: true,
      );
      expect(policy.shouldAutoImport(0.8), isTrue);
      expect(policy.shouldAutoImport(0.79), isFalse);
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
      expect(policy.autoImportThreshold, 0.8);
    });

    test('fromSettings falls back to defaults for missing values', () {
      final policy = DetectionPolicy.fromSettings(const {});
      expect(policy.enabled, DetectionPolicy.defaults.enabled);
      expect(policy.autoImportEnabled, DetectionPolicy.defaults.autoImportEnabled);
      expect(policy.autoImportThreshold, DetectionPolicy.defaults.autoImportThreshold);
      expect(policy.salaryDetectionEnabled, DetectionPolicy.defaults.salaryDetectionEnabled);
    });

    test('fromSettings rejects invalid threshold values', () {
      final policy = DetectionPolicy.fromSettings(const {'detectionAutoImportThreshold': 'xyz'});
      expect(policy.autoImportThreshold, 0.9);
      final overflow = DetectionPolicy.fromSettings(const {'detectionAutoImportThreshold': '2.0'});
      expect(overflow.autoImportThreshold, 0.9);
      final negative = DetectionPolicy.fromSettings(const {'detectionAutoImportThreshold': '-1'});
      expect(negative.autoImportThreshold, 0.9);
    });
  });
}
