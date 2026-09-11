package dev.robprian.dompet

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges locally-detected bank/QRIS notifications from Android to Flutter.
 *
 * Raw notification content is never logged or persisted. The service forwards
 * only the package name, title, and body through an in-process broadcast that
 * the Flutter engine (when running) receives over [CHANNEL].
 */
object TransactionNotificationBridge {
    const val CHANNEL = "dompet/notifications"
    const val CONTROL_CHANNEL = "dompet/notifications/control"
    const val ACTION_NOTIFICATION = "dev.robprian.dompet.NOTIFICATION_RECEIVED"
    const val EXTRA_PACKAGE = "notification_package"
    const val EXTRA_TITLE = "notification_title"
    const val EXTRA_TEXT = "notification_text"
    const val EXTRA_TIME = "notification_time"

    private var messenger: BinaryMessenger? = null
    private var methodChannel: MethodChannel? = null

    private val receiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val m = messenger ?: return
            MethodChannel(m, CHANNEL).invokeMethod("onTransactionNotification", payloadFrom(intent))
        }
    }

    /** Produces a broadcast intent for a new notification candidate. */
    fun intentFor(context: Context, pkg: String, title: String, text: String, postTime: Long): Intent {
        return Intent(ACTION_NOTIFICATION).apply {
            setPackage(context.packageName)
            putExtra(EXTRA_PACKAGE, pkg)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_TIME, postTime)
        }
    }

    /** Registers the broadcast receiver and the control channel handler. */
    fun register(context: Context, m: BinaryMessenger) {
        messenger = m
        methodChannel = MethodChannel(m, CONTROL_CHANNEL)
        methodChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "openNotificationAccessSettings" -> {
                    context.startActivity(
                        Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                "isNotificationListenerEnabled" -> {
                    result.success(isListenerEnabled(context))
                }
                else -> result.notImplemented()
            }
        }
        // Android 14+ (targetSdk 34+) requires an explicit export flag for
        // runtime receivers; otherwise registerReceiver throws SecurityException
        // during Activity creation and the app force-closes on launch.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            context.registerReceiver(
                receiver,
                IntentFilter(ACTION_NOTIFICATION),
                Context.RECEIVER_NOT_EXPORTED,
            )
        } else {
            context.registerReceiver(receiver, IntentFilter(ACTION_NOTIFICATION))
        }
    }

    /** Unregisters the broadcast receiver and control channel handler. */
    fun unregister(context: Context) {
        runCatching { context.unregisterReceiver(receiver) }
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        messenger = null
    }

    /**
     * Checks whether [TransactionNotificationListenerService] is enabled.
     * Reads the secure-settings listener list directly, so no extra
     * dependency is required. Raw notification content is never touched here.
     */
    private fun isListenerEnabled(context: Context): Boolean {
        val component = ComponentName(context, TransactionNotificationListenerService::class.java)
        val enabled =
            Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners").orEmpty()
        return enabled.split(":").any { ComponentName.unflattenFromString(it) == component }
    }

    private fun payloadFrom(intent: Intent): Map<String, Any?> = mapOf(
        EXTRA_PACKAGE to intent.getStringExtra(EXTRA_PACKAGE),
        EXTRA_TITLE to intent.getStringExtra(EXTRA_TITLE),
        EXTRA_TEXT to intent.getStringExtra(EXTRA_TEXT),
        EXTRA_TIME to intent.getLongExtra(EXTRA_TIME, 0L),
    )
}