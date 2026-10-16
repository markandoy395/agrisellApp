# Android waybill printing — 2026-10-16

The print service tried an external HTML data URL, then fell back to launching
an app-cache `file://` URL. Android rejected the private file URI with
`FileUriExposedException`. The UI interpolated the exception into its snackbar,
exposing a long stack trace and internal file paths.

Android now uses the `agrisell/waybill_print` method channel to render the
existing escaped HTML in a local WebView and open the system PrintManager
dialog after loading finishes. The WebView disables JavaScript, network loads,
file access and content access. Its print adapter retains it until printing
finishes; activity destruction and a loading timeout also release resources.
Concurrent jobs fail with a short code. No file URI is shared with another app.

Non-Android printing retains the external HTML data URL, without the unsafe
file fallback. Saving HTML remains a separate operation. Print failures,
including a false launch result, display a short retry message without exception
details. No database queries, storage policies or authorization rules changed.

Flutter regression tests cover Android method-channel arguments, failure
handling without a file fallback, safe UI errors, existing document escaping,
and rider/farmer waybill entry points. These checks do not verify a physical
printer or the system dialog on a device. Native changes require a full rebuild
and reinstall/run; Flutter hot reload cannot load them.
