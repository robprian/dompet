import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload.freezed.dart';

/// A raw notification received from an Android bank/e-wallet/QRIS app.
///
/// This object exists only transiently inside the parsing pipeline and is
/// never persisted in its raw form.
@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required String package,
    required String title,
    required String body,
    required DateTime postedAt,
  }) = _NotificationPayload;
}
