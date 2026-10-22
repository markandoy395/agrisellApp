# Notification permission flow

Notification permission is optional. Startup and account activation register a
device token only when permission is already enabled; neither requests permission.

## Contextual offers

The app offers a custom explanation after a successful action:

- Buyer: placing an order, with order confirmation and delivery update benefits.
- Farmer: publishing a product, with new order, message, and pickup benefits.
- Rider: going online, after the location and availability checks finish, with
  delivery request and customer message benefits.

Only one notification explanation/system request can be active. The automatic
explanation is offered once per app installation, shared across accounts because
the operating system permission belongs to the app on that device. Dismissing it
with **Not now** does not request system permission. Users can deliberately
reopen it from the Notifications screen for their role.

**Turn on** invokes Firebase Messaging's system permission request. The local
notification plugin does not issue a second request. After denial, the explanation
shows **Open Settings**. The Notifications screen also provides a one-tap Settings
link. Returning after enabling notifications refreshes the status and registers
the device for the currently authenticated account.

Android reports denied both before its first request and after denial. A device
preference records an attempted request; subsequent denied states offer Settings
instead of repeating the system request. Previously installed versions have no
such preference, so one explicit attempt may precede Settings recovery.

## Platform and device verification

This project configures Firebase and a native app for Android. Other platforms
hide these controls; iOS support requires an iOS project and Firebase setup.
The native link opens Android's app notification settings, with app details as a
fallback and manual directions if both routes fail.

On a device, verify fresh installation, Not now, approval, denial, Settings
return with permission enabled/unchanged, an already-granted upgraded install,
and each role's successful action. Also verify location completes before the
rider notification explanation and that failed actions never trigger it.
Widget tests cover permission decisions, duplicate prevention, Settings recovery,
and narrow screens with large text; they do not display real operating system UI.
