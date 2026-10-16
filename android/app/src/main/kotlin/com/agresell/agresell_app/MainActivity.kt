package com.agresell.agresell_app

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest
import com.google.android.gms.auth.api.identity.Identity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
    companion object {
        private const val PHONE_NUMBER_REQUEST_CODE = 1001
    }

    private var pendingPhoneResult: MethodChannel.Result? = null
    private var waybillPrinter: WaybillPrinter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView ->
                splashScreenView.remove()
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        waybillPrinter = WaybillPrinter(this).also { printer ->
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "agrisell/waybill_print",
            ).setMethodCallHandler(printer::handle)
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "agrisell/device_phone_number",
        ).setMethodCallHandler { call, result ->
            if (call.method != "requestPhoneNumber") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            requestPhoneNumber(result)
        }
    }

    override fun onDestroy() {
        waybillPrinter?.dispose()
        waybillPrinter = null
        super.onDestroy()
    }

    private fun requestPhoneNumber(result: MethodChannel.Result) {
        if (pendingPhoneResult != null) {
            result.error("request_in_progress", "A phone number request is already open.", null)
            return
        }

        pendingPhoneResult = result
        val request = GetPhoneNumberHintIntentRequest.builder().build()
        Identity.getSignInClient(this).getPhoneNumberHintIntent(request)
            .addOnSuccessListener { pendingIntent ->
                try {
                    startIntentSenderForResult(
                        pendingIntent.intentSender,
                        PHONE_NUMBER_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0,
                    )
                } catch (exception: Exception) {
                    pendingPhoneResult = null
                    result.error("phone_number_unavailable", exception.message, null)
                }
            }
            .addOnFailureListener { exception ->
                pendingPhoneResult = null
                result.error("phone_number_unavailable", exception.message, null)
            }
    }

    @Deprecated("Deprecated in the Android Activity API, required by FlutterActivity")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PHONE_NUMBER_REQUEST_CODE) return

        val channelResult = pendingPhoneResult ?: return
        pendingPhoneResult = null
        if (resultCode != Activity.RESULT_OK || data == null) {
            channelResult.success(null)
            return
        }

        try {
            val phoneNumber = Identity.getSignInClient(this)
                .getPhoneNumberFromIntent(data)
            channelResult.success(phoneNumber)
        } catch (exception: Exception) {
            channelResult.error("phone_number_unavailable", exception.message, null)
        }
    }
}
