package com.agresell.agresell_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Opens this app's notification settings, falling back to its app settings. */
object NotificationSettingsChannel {
    fun register(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, "agrisell/notification_settings")
            .setMethodCallHandler { call, result ->
                if (call.method != "openNotificationSettings") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                } else {
                    appSettingsIntent(activity)
                }
                val opened = try {
                    activity.startActivity(intent)
                    true
                } catch (_: Exception) {
                    try {
                        activity.startActivity(appSettingsIntent(activity))
                        true
                    } catch (_: Exception) {
                        false
                    }
                }
                result.success(opened)
            }
    }

    private fun appSettingsIntent(activity: Activity) =
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            .setData(Uri.parse("package:${activity.packageName}"))
}
