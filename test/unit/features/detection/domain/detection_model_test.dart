import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionDetectionModel model() {
  final now = DateTime.utc(2026, 3, 15, 10, 30);
  return TransactionDetectionModel(
    id: 'd1',
    fingerprint: 'fp-d1',
    sourcePackage: 'com.bank.app',
    type: DetectionTransactionType.expense,
    amount: 25000,
    confidence: 0.95,
    confidenceTier: ConfidenceTier.high,
    method: PaymentMethod.qris,
    parserVersion: 'qris-v1',
    status: DetectionStatus.pending,
    occurredAt: now,
    createdAt: now,
    merchant: 'KOPI ABC',
  );
}

void main() {
  group('TransactionDetectionModel', () {
    test('exposes display helpers', () {
      final detection = model();
      expect(detection.methodLabel, 'QRIS');
      expect(detection.partyName, 'KOPI ABC');
    });

    test('falls back to the counterparty for display', () {
      final detection = model().copyWith(merchant: null, counterparty: 'BUDI');
      expect(detection.partyName, 'BUDI');
    });

    test('labels every payment method', () {
      for (final method in PaymentMethod.values) {
        expect(model().copyWith(method: method).methodLabel.isNotEmpty, isTrue);
      }
    });

    test('supports copyWith for review updates', () {
      final updated = model().copyWith(status: DetectionStatus.imported, accountId: 'acc-1');
      expect(updated.status, DetectionStatus.imported);
      expect(updated.accountId, 'acc-1');
      expect(updated.id, 'd1');
    });
  });

  group('SalaryProfileModel', () {
    test('stores salary profile fields', () {
      const profile = SalaryProfileModel(
        id: 's1',
        amount: 10000000,
        dayOfMonth: 25,
        averageConfidence: 0.9,
        occurrenceCount: 2,
      );
      expect(profile.amount, 10000000);
      expect(profile.dayOfMonth, 25);
      expect(profile.occurrenceCount, 2);
    });
  });
}
