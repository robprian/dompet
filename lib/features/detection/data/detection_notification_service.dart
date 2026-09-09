import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';

/// Runtime service connecting Android notifications to the local import engine.
class DetectionNotificationService {
  /// Creates a runtime notification service.
  DetectionNotificationService({required this.bridge, required this.importService});

  /// Android/Dart platform bridge.
  final NotificationBridge bridge;

  /// Local parser and ledger orchestration service.
  final DetectionImportService importService;

  /// Starts receiving notification candidates.
  void start() {
    bridge.register(process);
  }

  /// Stops receiving notification candidates.
  void stop() {
    bridge.dispose();
  }

  /// Processes one payload and returns the local outcome.
  Future<ImportOutcome> process(NotificationPayload payload) => importService.handle(payload);

  /// Requests Android notification access settings.
  Future<bool> requestNotificationAccess() => bridge.requestAccess();

  /// Reads Android notification access state.
  Future<bool> isNotificationAccessEnabled() => bridge.isListenerEnabled();
}
