# Shared bottom messages

All application snackbars use `AppSnackBarMessenger.showAppSnackBar` from
`lib/core/widgets/app_snack_bar.dart`. Import that extension and pass the normal
`SnackBar` content. Feature code must not call `showSnackBar` directly.

The shared `AppSnackBarPanel` and `AppSnackBarStyles` own the inset background,
compact padding, readable text, localized close button and scrollable height
limit. Changes to this presentation apply to buyer, farmer and rider messages.
The rider delivery helper is only a convenience wrapper retaining its six-second
duration; it no longer has separate presentation or style implementations.

The panel uses a transparent native snackbar around its inset surface. Default
fixed placement keeps it within Scaffold's snackbar area above footer/navigation
controls, including with tall floating action buttons. The content limit updates
from MediaQuery when the viewport, text scaling or keyboard changes. Long content
scrolls rather than growing without a bound. Normal message content takes only
its required height. Existing background colors, explicit close-icon choices,
action callbacks, persistence, explicit extension durations and replacement
behavior remain supported. The default extension duration is two seconds;
deadline information and rider delivery messages explicitly use six seconds.

2026-10-16 migration includes the shared acceptance-deadline information used by
buyers and farmers, chat errors, review appeals, support flows, report exports
and waybill actions. Source search found no remaining direct `showSnackBar`
calls outside the central extension. No authorization or database queries changed.

Verification covers actual buyer/farmer deadline messages on a 320-pixel viewport
with enlarged text; rider portrait/landscape and rotation; keyboard and tall-FAB
placement; dismissal, replacement and action completion. Supporting export,
support, appeal and waybill regressions also pass: 29 tests across eight suites.
Keyboard tests cover both resizing and non-resizing Scaffolds. Device screenshots
and every message on every route have not been verified end to end.
