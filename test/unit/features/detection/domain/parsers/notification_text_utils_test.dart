import 'package:dompet/features/detection/domain/parsers/notification_text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractAmount', () {
    test('parses QRIS amounts with dot separators', () {
      expect(extractAmount('Pembayaran QRIS Rp25.000 di KOPI ABC'), 25000);
    });

    test('parses amounts with spaces and IDR prefix', () {
      expect(extractAmount('Transfer masuk Rp 5.000.000 dari BUDI'), 5000000);
      expect(extractAmount('IDR 1.500.000 diterima'), 1500000);
    });

    test('parses millions with decimal cents dropped', () {
      expect(extractAmount('Rp 1.500.000,00 berhasil'), 1500000);
    });

    test('parses bare amounts after Rp', () {
      expect(extractAmount('Rp750000 terkirim'), 750000);
    });

    test('returns null when no amount is present', () {
      expect(extractAmount('Transaksi berhasil tanpa nominal'), isNull);
    });

    test('returns null for zero or empty amounts', () {
      expect(extractAmount('Saldo Rp0'), isNull);
    });
  });

  group('extractPartyAfter', () {
    test('extracts merchant after di', () {
      expect(extractPartyAfter('Pembayaran QRIS Rp25.000 di KOPI ABC', const ['di KOPI']), isNull);
      expect(extractPartyAfter('Pembayaran QRIS Rp25.000 di KOPI ABC', const ['di']), 'KOPI ABC');
    });

    test('extracts counterparty after ke', () {
      expect(extractPartyAfter('Transfer Rp750.000 ke BUDI', const ['ke']), 'BUDI');
    });

    test('returns null when the marker is absent', () {
      expect(extractPartyAfter('Saldo bertambah Rp10.000', const ['ke']), isNull);
    });
  });

  group('normalizeText', () {
    test('lowercases and collapses whitespace', () {
      expect(normalizeText('  Pembayaran   QRIS  '), 'pembayaran qris');
    });

    test('reports rupiah presence', () {
      expect(containsRupiahAmount('Rp25.000'), isTrue);
      expect(containsRupiahAmount('tidak ada nominal'), isFalse);
    });
  });
}
