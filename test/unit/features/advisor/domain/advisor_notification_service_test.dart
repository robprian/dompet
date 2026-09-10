import 'package:dompet/core/services/notification_service.dart';
import 'package:dompet/features/advisor/domain/advisor_notification_service.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService notifications;
  late AdvisorNotificationService service;

  setUp(() {
    notifications = MockNotificationService();
    when(
      () => notifications.showNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    service = AdvisorNotificationService(notifications: notifications);
  });

  test('salary imports trigger a salary notification', () async {
    await service.handleImportOutcome(
      const ImportOutcome(type: ImportOutcomeType.imported, amount: 10000000, isSalary: true),
    );
    verify(
      () => notifications.showNotification(
        id: 91002,
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: 'advisor',
      ),
    ).called(1);
  });

  test('large non-salary imports trigger a large-transaction notification', () async {
    await service.handleImportOutcome(
      const ImportOutcome(type: ImportOutcomeType.imported, amount: 5000000, isSalary: false),
    );
    verify(
      () => notifications.showNotification(
        id: 91003,
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: 'advisor',
      ),
    ).called(1);
  });

  test('review outcomes trigger a review notification', () async {
    await service.handleImportOutcome(
      const ImportOutcome(type: ImportOutcomeType.review, amount: 25000, confidence: 0.8),
    );
    verify(
      () => notifications.showNotification(
        id: 91001,
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: 'detection-review',
      ),
    ).called(1);
  });

  test('duplicates and discards stay silent', () async {
    await service.handleImportOutcome(const ImportOutcome(type: ImportOutcomeType.duplicate));
    await service.handleImportOutcome(const ImportOutcome(type: ImportOutcomeType.discarded));
    verifyNever(
      () => notifications.showNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    );
  });
}
