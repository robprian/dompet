package dev.robprian.dompet

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Bridges locally-detected bank/QRIS notifications from Android to Flutter.
 *
 * The transaction stream is delivered through a [MethodChannel] attached to a
 * Dart-cached [BinaryMessenger]. When the Flutter engine is not running, the
 * last candidate is retained so Dart can drain it on next launch.
 */
object TransactionNotificationBridge {
    const val CHANNEL = "dompet/notifications"
    const val ACTION_NOTIFICATION = "dev.robprian.dompet.NOTIFICATION_RECEIVED"
    const val EXTRA_PACKAGE = "notification_package"
    const val EXTRA_TITLE = "notification_title"
    const val EXTRA_TEXT = "notification_text"
    const val EXTRA_TIME = "notification_time"

    private const val PREFS = "dompet_notification_bridge"
    private const val KEY_CANDIDATE = "pending_candidate_json"
    private const val MAX_CANDIDATES = 8

    private var cachedMessenger: BinaryMessenger? = null
    private var channel: MethodChannel? = null
    private var lastCandidateJson: String? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val messenger = cachedMessenger ?: return
            val call = MethodChannel(messenger, CHANNEL)
            call.invokeMethod("onTransactionNotification", payloadFrom(intent))
            prune(context)
        }
    }

    /** Produces a broadcast intent for a new notification candidate. */
    fun intentFor(context: Context, pkg: String, title: String, text: String, postTime: Long): Intent {
        val candidate = JSONObject()
            .put(EXTRA_PACKAGE, pkg)
            .put(EXTRA_TITLE, title)
            .put(EXTRA_TEXT, text)
            .put(EXTRA_TIME, postTime)
        val lastJson = candidate.toString()

        // Retain the most recent candidate locally (private prefs, capped) so
        // Dart can drain it after a cold start.
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val prior = prefs.getString(KEY_CANDIDATE, null)
        val updated = if (prior == null) lastJson else "$prior\u0001$lastJson"
        prefs.edit().putString(KEY_CANDIDATE, updated).apply()

        return Intent(ACTION_NOTIFICATION).apply {
            setPackage(context.packageName)
            putExtra(EXTRA_PACKAGE, pkg)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_TIME, postTime)
        }
    }

    /** Returns the JSON payload for a received broadcast intent. */
    private fun payloadFrom(intent: Intent): Map<String, Any?> = mapOf(
        EXTRA_PACKAGE to intent.getStringExtra(EXTRA_PACKAGE),
        EXTRA_TITLE to intent.getStringExtra(EXTRA_TITLE),
        EXTRA_TEXT to intent.getStringExtra(EXTRA_TEXT),
        EXTRA_TIME to intent.getLongExtra(EXTRA_TIME, 0L),
    )

    /** Returns all locally retained candidates (cold-start drain) and clears them. */
    fun drainPending(context: Context): List<Map<String, Any?>> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_CANDIDATE, null) ?: return emptyList()
        val entries = mutableListOf<Map<String, Any?>>()
        raw.split('\u0001').forEach { piece ->
            if (piece.isBlank()) return@forEach
            try {
                val json = JSONObject(piece)
                entries.add(
                    mapOf(
                        EXTRA_PACKAGE to json.optString(EXTRA_PACKAGE),
                        EXTRA_TITLE to json.optString(EXTRA_TITLE),
                        EXTRA_TEXT to json.optString(EXTRA_TEXT),
                        EXTRA_TIME to json.optLong(EXTRA_TIME),
                    ),
                )
            } catch (_: Exception) {
                // Skip a malformed entry; do not crash the drain.
            }
        }
        prune(context)
        return entries
    }

    private fun prune(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_CANDIDATE, null) ?: return
        val pieces = raw.split('\u0001').filter { it.isNotBlank() }
        if (pieces.size <= MAX_CANDIDATES) return
        prefs.edit().putString(KEY_CANDIDATE, pieces.takeLast(MAX_CANDIDATES).joinToString("\u0001")).apply()
    }

    /** Registers the broadcast receiver against the provided messenger. */
    fun register(context: Context, messenger: BinaryMessenger) {
        cachedMessenger = messenger
        channel = MethodChannel(messenger, CHANNEL)
        val filter = IntentFilter(ACTION_NOTIFICATION)
        context.registerReceiver(receiver, filter)
    }

    /** Unregisters the broadcast receiver when the messenger is disposed. */
    fun unregister(context: Context) {
        runCatching { context.unregisterReceiver(receiver) }
        cachedMessenger = null
        channel = null
    }
}
