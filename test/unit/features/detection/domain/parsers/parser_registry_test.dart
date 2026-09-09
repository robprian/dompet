import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/parsers/parser_registry.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationPayload payload(String body) {
  return NotificationPayload(
    package: 'com.bank.app',
    title: '',
    body: body,
    postedAt: DateTime.utc(2026, 3, 15, 10, 30),
  );
}

void main() {
  group('NotificationParserRegistry', () {
    test('returns the highest confidence candidate', () {
      const registry = NotificationParserRegistry();
      final candidate = registry.parse(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil'));
      expect(candidate, isNotNull);
      expect(candidate!.parserVersion, 'qris-v1');
    });

    test('returns null for unrecognized notifications', () {
      const registry = NotificationParserRegistry();
      expect(registry.parse(payload('Cuaca hari ini cerah')), isNull);
      expect(registry.parse(payload('')), isNull);
    });

    test('supports an empty parser chain', () {
      const registry = NotificationParserRegistry(parsers: []);
      expect(registry.parse(payload('Pembayaran QRIS Rp25.000 di KOPI ABC berhasil')), isNull);
    });
  });
}
