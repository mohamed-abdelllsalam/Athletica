package com.example.athletica

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "athletica/notification_launch")
            .setMethodCallHandler { call, result ->
                if (call.method != "getSentTime") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val requestedId = call.argument<String>("messageId")
                val extras = intent?.extras
                val launchId = extras?.getString("google.message_id")
                    ?: extras?.getString("message_id")
                // Never substitute the timestamp from a different notification.
                if (requestedId.isNullOrEmpty() || requestedId != launchId) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                val timestamp = extras?.get("google.sent_time")
                val sentTime = when (timestamp) {
                    is Number -> timestamp.toLong()
                    is String -> timestamp.toLongOrNull()
                    else -> null
                }
                result.success(sentTime?.takeIf { it > 0 })
            }
    }

    override fun onNewIntent(intent: Intent) {
        // Keep timestamp recovery aligned with the latest notification tap.
        setIntent(intent)
        super.onNewIntent(intent)
    }
}
