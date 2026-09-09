import 'package:dompet/core/services/notification_service.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fires local notifications for detection and advisor events.
class AdvisorNotificationService {
  /// Creates the notification service.
  AdvisorNotificationService({NotificationService? notifications}) : _notifications = notifications ?? notificationService;

  final NotificationService _notifications;

  /// Notifies about a newly detected transaction awaiting review.
  Future<void> notifyDetectionReview({required int amount, required double confidence}) async {
    await _notifications.showNotification(
      id: _reviewId,
      title: t.settings.newTransactionDetected,
      body: t.settings.detectionReviewBody(amount: amount, confidence: _percent(confidence)),
      payload: 'detection-review',
    );
  }

  /// Notifies when a likely salary payment was imported.
  Future<void> notifySalary({required int amount}) async {
    await _notifications.showNotification(
      id: _salaryId,
      title: t.settings.salaryDetected,
      body: t.settings.salaryDetectedBody(amount: amount),
      payload: 'advisor',
    );
  }

  /// Notifies about an unusually large transaction.
  Future<void> notifyLargeTransaction({required int amount}) async {
    await _notifications.showNotification(
      id: _largeTransactionId,
      title: t.settings.largeTransactionDetected,
      body: t.settings.largeTransactionBody(amount: amount),
      payload: 'advisor',
    );
  }

  /// Routes an import outcome to the appropriate advisor notification.
  Future<void> handleImportOutcome(ImportOutcome outcome) async {
    final amount = outcome.amount ?? 0;
    switch (outcome.type) {
      case ImportOutcomeType.imported:
        if (outcome.isSalary == true) {
          await notifySalary(amount: amount);
        } else if (amount >= _largeThreshold) {
          await notifyLargeTransaction(amount: amount);
        }
      case ImportOutcomeType.review:
        await notifyDetectionReview(amount: amount, confidence: outcome.confidence ?? 0.5);
      case ImportOutcomeType.discarded:
      case ImportOutcomeType.duplicate:
        break;
    }
  }

  static String _percent(double value) => '${(value * 100).round()}%';

  static const int _reviewId = 91001;
  static const int _salaryId = 91002;
  static const int _largeTransactionId = 91003;
  static const int _largeThreshold = 2500000;
}

/// Provides the local advisor notification dispatcher.
final advisorNotificationServiceProvider = Provider<AdvisorNotificationService>(
  (ref) => AdvisorNotificationService(),
);
