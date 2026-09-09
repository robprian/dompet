import 'package:dompet/features/detection/data/detection_notification_service.dart';
import 'package:dompet/features/detection/data/notification_bridge.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/services/detection_import_service.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationBridge extends Mock implements NotificationBridge {}

class MockImportService extends Mock implements DetectionImportService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      NotificationPayload(
        package: 'com.bank.app',
        title: '',
        body: '',
        postedAt: DateTime.utc(2026, 1, 1),
      ),
    );
  });

  late MockNotificationBridge bridge;
  late MockImportService importService;
  late DetectionNotificationService service;

  setUp(() {
    bridge = MockNotificationBridge();
    importService = MockImportService();
    service = DetectionNotificationService(bridge: bridge, importService: importService);
  });

  NotificationPayload payload() {
    return NotificationPayload(
      package: 'com.bank.app',
      title: '',
      body: 'Pembayaran QRIS Rp25.000 di KOPI ABC berhasil',
      postedAt: DateTime.utc(2026, 3, 15, 10, 30),
    );
  }

  test('start and stop register and dispose the bridge', () {
    service.start();
    verify(() => bridge.register(any())).called(1);
    service.stop();
    verify(bridge.dispose).called(1);
  });

  test('process delegates to the import service and notifies listeners', () async {
    const outcome = ImportOutcome(type: ImportOutcomeType.imported, amount: 25000);
    when(() => importService.handle(any())).thenAnswer((_) async => outcome);

    var notified = 0;
    final wired = DetectionNotificationService(
      bridge: bridge,
      importService: importService,
      onProcessed: (_) async => notified++,
    );
    final result = await wired.process(payload());

    expect(result, outcome);
    expect(notified, 1);
  });

  test('requestNotificationAccess delegates to the bridge', () async {
    when(bridge.requestAccess).thenAnswer((_) async => true);
    expect(await service.requestNotificationAccess(), isTrue);
  });

  test('isNotificationAccessEnabled delegates to the bridge', () async {
    when(bridge.isListenerEnabled).thenAnswer((_) async => false);
    expect(await service.isNotificationAccessEnabled(), isFalse);
  });
}
