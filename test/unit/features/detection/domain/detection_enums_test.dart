import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    test('confidence tiers cover the documented bands', () {
      expect(
        ConfidenceTier.values,
        containsAll([ConfidenceTier.high, ConfidenceTier.likely, ConfidenceTier.uncertain, ConfidenceTier.rejected]),
      );
      expect(
        DetectionStatus.values,
        containsAll([DetectionStatus.pending, DetectionStatus.imported, DetectionStatus.ignored]),
      );
    });
  });
}
