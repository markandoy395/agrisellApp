package com.agresell.agresell_app

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.print.PrintAttributes
import android.print.PrintManager
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Renders app-generated HTML locally; never exposes a private file URI. */
class WaybillPrinter(private val activity: Activity) {
    private var webView: WebView? = null
    private var pendingResult: MethodChannel.Result? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { fail() }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "printHtml") {
            result.notImplemented()
            return
        }
        if (webView != null) {
            result.error("print_busy", "A waybill print job is already open.", null)
            return
        }
        val html = call.argument<String>("html")
        val jobName = call.argument<String>("jobName")
        if (html.isNullOrBlank() || jobName.isNullOrBlank()) {
            result.error("invalid_document", "A waybill document is required.", null)
            return
        }
        pendingResult = result
        handler.postDelayed(timeout, 30_000)
        try {
            webView = WebView(activity).apply {
                settings.javaScriptEnabled = false
                settings.allowFileAccess = false
                settings.allowContentAccess = false
                settings.blockNetworkLoads = true
                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView, url: String) {
                        if (pendingResult == null) return
                        openPrintDialog(view, jobName)
                    }

                    override fun onReceivedError(
                        view: WebView,
                        request: WebResourceRequest,
                        error: WebResourceError,
                    ) {
                        if (request.isForMainFrame) fail()
                    }
                }
                loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
            }
        } catch (_: Exception) {
            fail()
        }
    }

    private fun openPrintDialog(view: WebView, jobName: String) {
        try {
            val manager = activity.getSystemService(Context.PRINT_SERVICE) as PrintManager
            val adapter = WaybillPrintAdapter(view.createPrintDocumentAdapter(jobName)) {
                dispose()
            }
            manager.print(jobName, adapter, PrintAttributes.Builder().build())
            handler.removeCallbacks(timeout)
            val result = pendingResult
            pendingResult = null
            result?.success(true)
        } catch (_: Exception) {
            fail()
        }
    }

    private fun fail() {
        val result = pendingResult
        pendingResult = null
        result?.error("print_unavailable", "The waybill could not be printed.", null)
        dispose()
    }

    fun dispose() {
        handler.removeCallbacks(timeout)
        val result = pendingResult
        pendingResult = null
        result?.error("print_cancelled", "Waybill printing was closed.", null)
        webView?.destroy()
        webView = null
    }
}
