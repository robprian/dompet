package dev.robprian.dompet

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

/**
 * Receives notification metadata locally and forwards only normalized-safe
 * notification candidates to the Flutter process.
 *
 * Raw notification content is never logged or persisted. A full Flutter
 * process may not be running when Android delivers an event, so the service
 * uses a local broadcast consumed by the platform bridge when available.
 */
class TransactionNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) return

        val extras = sbn.notification.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        if (title.isBlank() && text.isBlank()) return

        // Deliberately do not log title/text: bank notifications are sensitive.
        val intent = TransactionNotificationBridge.intentFor(this, sbn.packageName, title, text, sbn.postTime)
        sendBroadcast(intent)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification removed")
    }

    private companion object {
        const val TAG = "DompetNotification"
    }
}
