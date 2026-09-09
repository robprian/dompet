import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/parsers/indonesian_parsers.dart';
import 'package:dompet/features/detection/domain/parsers/parser_registry.dart';
import 'package:dompet/features/detection/domain/transaction_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationPayload payload({String title = '', required String body, String package = 'com.bank.app'}) {
  return NotificationPayload(
    package: package,
    title: title,
    body: body,
    postedAt: DateTime.utc(2026, 3, 15, 10, 30),
  );
}

void main() {
  const qris = QrisParser();
  const bank = BankTransferParser();
  const wallet = EWalletParser();
  const generic = GenericBankParser();

  group('QrisParser', () {
    test('parses canonical QRIS payment', () {
      final candidate = qris.parse(payload(body: 'Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));
      expect(candidate, isNotNull);
      expect(candidate!.amount, 25000);
      expect(candidate.type, DetectionTransactionType.expense);
      expect(candidate.method, PaymentMethod.qris);
      expect(candidate.merchant, 'KOPI ABC');
      expect(candidate.confidence, greaterThanOrEqualTo(0.9));
      expect(candidate.confidenceTier, ConfidenceTier.high);
      expect(candidate.parserVersion, 'qris-v1');
    });

    test('parses QRIS with alternate wording', () {
      final candidate = qris.parse(payload(body: 'Pembelian QRIS Rp 125.000 di Toko Berkah Jaya sukses'));
      expect(candidate, isNotNull);
      expect(candidate!.amount, 125000);
      expect(candidate.merchant, isNotNull);
    });

    test('rejects failed QRIS payments', () {
      expect(qris.parse(payload(body: 'Pembayaran QRIS Rp25.000 di KOPI ABC gagal')), isNull);
    });

    test('does not match notifications without QRIS marker', () {
      expect(qris.parse(payload(body: 'Pembayaran Rp25.000 di KOPI ABC berhasil')), isNull);
    });
  });

  group('BankTransferParser', () {
    test('parses incoming transfer', () {
      final candidate = bank.parse(payload(body: 'Transfer masuk Rp5.000.000 dari BUDI berhasil'));
      expect(candidate, isNotNull);
      expect(candidate!.type, DetectionTransactionType.income);
      expect(candidate.amount, 5000000);
      expect(candidate.counterparty, 'BUDI');
      expect(candidate.method, PaymentMethod.bank);
      expect(candidate.confidence, greaterThanOrEqualTo(0.7));
    });

    test('parses outgoing transfer', () {
      final candidate = bank.parse(payload(body: 'Transfer Rp750.000 ke SITI berhasil'));
      expect(candidate, isNotNull);
      expect(candidate!.type, DetectionTransactionType.expense);
      expect(candidate.counterparty, 'SITI');
    });

    test('detects salary-flavored income text', () {
      final candidate = bank.parse(payload(body: 'Gaji bulanan Rp10.000.000 diterima'));
      expect(candidate, isNotNull);
      expect(candidate!.type, DetectionTransactionType.income);
      expect(candidate.amount, 10000000);
    });

    test('rejects failed transfers', () {
      expect(bank.parse(payload(body: 'Transfer Rp100.000 ke SITI gagal diproses')), isNull);
    });

    test('rejects amount-less notifications', () {
      expect(bank.parse(payload(body: 'Transfer berhasil')), isNull);
    });
  });

  group('EWalletParser', () {
    test('parses e-wallet payment', () {
      final candidate = wallet.parse(payload(body: 'Kamu bayar Rp35.000 di GoFood dengan GoPay', package: 'com.gojek'));
      expect(candidate, isNotNull);
      expect(candidate!.method, PaymentMethod.ewallet);
      expect(candidate.amount, 35000);
    });

    test('does not match unknown notifications', () {
      expect(wallet.parse(payload(body: 'Promo spesial hari ini')), isNull);
    });
  });

  group('GenericBankParser', () {
    test('parses balance notifications', () {
      final candidate = generic.parse(
        payload(body: 'Mutasi rekening: dana masuk sebesar Rp2.000.000. Saldo Rp8.000.000'),
      );
      expect(candidate, isNotNull);
      expect(candidate!.amount, 2000000);
    });

    test('rejects unrelated texts', () {
      expect(generic.parse(payload(body: 'Halo, ada promo baru minggu ini')), isNull);
    });
  });
}
