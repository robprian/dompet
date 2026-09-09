import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      expect(payload.postedAt, DateTime.utc(2026, 3, 15));
    });

    test('supports value equality', () {
      final postedAt = DateTime.utc(2026, 3, 15);
      final a = NotificationPayload(package: 'com.bank', title: 'Info', body: 'Rp25.000', postedAt: postedAt);
      final b = NotificationPayload(package: 'com.bank', title: 'Info', body: 'Rp25.000', postedAt: postedAt);
      expect(a, equals(b));
    });
  });
}
