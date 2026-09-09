import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      expect(outcome.amount, 25000);
      expect(outcome.confidence, 0.95);
      expect(outcome.isSalary, isFalse);
      expect(ImportOutcomeType.values.length, 4);
    });

    test('supports minimal construction', () {
      const outcome = ImportOutcome(type: ImportOutcomeType.discarded);
      expect(outcome.detectionId, isNull);
      expect(outcome.amount, isNull);
    });
  });
}
