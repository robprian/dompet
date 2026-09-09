import 'package:dompet/core/utils/logger.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:flutter/services.dart';

/// Bridge between the Android notification listener and the Dart pipeline.
class NotificationBridge {
  /// Creates the bridge with its platform channels.
  NotificationBridge({MethodChannel? channel, MethodChannel? control})
      : _channel = channel ?? const MethodChannel('dompet/notifications'),
        _control = control ?? const MethodChannel('dompet/notifications/control');

  /// Primary channel receiving parsed notification payloads.
  final MethodChannel _channel;

  /// Control channel for access state and deep links.
  final MethodChannel _control;

  Future<void> Function(NotificationPayload payload)? _onPayload;

  /// Starts listening for notification payloads from the platform side.
  void register(Future<void> Function(NotificationPayload payload) onPayload) {
    _onPayload = onPayload;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'onTransactionNotification') return null;
      final args = (call.arguments as Map<Object?, Object?>?) ?? const {};
      final title = args['notification_title'] as String? ?? '';
      final body = args['notification_text'] as String? ?? '';
      final pkg = args['notification_package'] as String? ?? '';
      final timeMs = (args['notification_time'] as num?)?.toInt() ?? 0;
      final postedAt = DateTime.fromMillisecondsSinceEpoch(timeMs, isUtc: true);
      await _onPayload?.call(NotificationPayload(package: pkg, title: title, body: body, postedAt: postedAt));
      return null;
    });
  }

  /// Disposes the payload listener.
  void dispose() {
    _channel.setMethodCallHandler(null);
    _onPayload = null;
  }

  /// Opens the Android notification-access settings screen.
  Future<bool> requestAccess() async {
    try {
      await _control.invokeMethod<void>('openNotificationAccessSettings');
      return true;
    } on PlatformException catch (e, st) {
      talker.handle(e, st, 'NotificationBridge.requestAccess');
      return false;
    } on MissingPluginException catch (e, st) {
      talker.handle(e, st, 'NotificationBridge.requestAccess');
      return false;
    }
  }

  /// Whether the listener service is enabled on this device.
  Future<bool> isListenerEnabled() async {
    try {
      final result = await _control.invokeMethod<bool>('isNotificationListenerEnabled');
      return result ?? false;
    } on PlatformException catch (e, st) {
      talker.handle(e, st, 'NotificationBridge.isListenerEnabled');
      return false;
    } on MissingPluginException catch (e, st) {
      talker.handle(e, st, 'NotificationBridge.isListenerEnabled');
      return false;
    }
  }
}
