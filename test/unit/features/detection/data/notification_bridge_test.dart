import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dompet/notifications');
  const control = MethodChannel('dompet/notifications/control');

  test('register invokes the payload callback for platform events', () async {
    final bridge = NotificationBridge();
    final received = <NotificationPayload>[];
    bridge.register((payload) async => received.add(payload));

    const codec = StandardMethodCodec();
    final data = codec.encodeMethodCall(
      const MethodCall('onTransactionNotification', {
        'notification_package': 'com.bank.app',
        'notification_title': 'Info',
        'notification_text': 'Pembayaran QRIS Rp25.000 di KOPI ABC',
        'notification_time': 1773570600000,
      }),
    );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'dompet/notifications',
      data,
      (_) {},
    );

    expect(received, hasLength(1));
    expect(received.first.package, 'com.bank.app');
    expect(received.first.body, 'Pembayaran QRIS Rp25.000 di KOPI ABC');
    bridge.dispose();
  });

  test('control calls return safe defaults without a platform handler', () async {
    final bridge = NotificationBridge();
    expect(await bridge.requestAccess(), isFalse);
    expect(await bridge.isListenerEnabled(), isFalse);
    bridge.dispose();
  });

  test('control calls delegate to the platform handler', () async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(control, (call) async {
      if (call.method == 'openNotificationAccessSettings') return null;
      if (call.method == 'isNotificationListenerEnabled') return true;
      return null;
    });

    final bridge = NotificationBridge();
    expect(await bridge.requestAccess(), isTrue);
    expect(await bridge.isListenerEnabled(), isTrue);
    bridge.dispose();
    messenger.setMockMethodCallHandler(control, null);
  });
}
