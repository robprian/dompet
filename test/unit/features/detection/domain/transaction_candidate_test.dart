import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/transaction_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionCandidate', () {
    test('fingerprints are stable for identical inputs', () {
      final postedAt = DateTime.utc(2026, 3, 15, 10, 30, 45);
      String fingerprint() => TransactionCandidate.makeFingerprint(
        sourcePackage: 'com.bank',
        amount: 25000,
        type: DetectionTransactionType.expense,
        merchant: 'KOPI ABC',
        referenceId: null,
        occurredAt: postedAt,
      );
      expect(fingerprint(), equals(fingerprint()));
    });

    test('fingerprints vary across packages, merchants, and minutes', () {
      final base = DateTime.utc(2026, 3, 15, 10, 30);
      String fingerprint({String package = 'com.bank', String? merchant = 'KOPI ABC', DateTime? at}) {
        return TransactionCandidate.makeFingerprint(
          sourcePackage: package,
          amount: 25000,
          type: DetectionTransactionType.expense,
          merchant: merchant,
          referenceId: null,
          occurredAt: at ?? base,
        );
      }

      expect(fingerprint(), isNot(equals(fingerprint(package: 'other.bank'))));
      expect(fingerprint(), isNot(equals(fingerprint(merchant: 'TOKO X'))));
      expect(fingerprint(), isNot(equals(fingerprint(at: base.add(const Duration(minutes: 2))))));
      expect(fingerprint(), equals(fingerprint(at: base.add(const Duration(seconds: 30)))));
    });

    test('canAutoImport follows the 0.90 tier rule', () {
      TransactionCandidate candidate(double confidence) => TransactionCandidate(
        fingerprint: 'f',
        amount: 25000,
        type: DetectionTransactionType.expense,
        method: PaymentMethod.qris,
        confidence: confidence,
        confidenceTier: ConfidenceTier.high,
        occurredAt: DateTime.utc(2026, 1, 1),
        parserVersion: 'qris-v1',
        sourcePackage: 'com.bank',
      );
      expect(candidate(0.9).canAutoImport, isTrue);
      expect(candidate(0.89).canAutoImport, isFalse);
    });
  });
}
