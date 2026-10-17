# Rider first Continue returns to login

The first Continue starts signup email verification, including authenticated
probing of an existing incomplete account. It does not explicitly navigate to
login. A loss of the previous application session during that request was handled
globally by replacing every route with login, including the public rider signup
form. That could discard entered credentials before the OTP page opened.

The app now installs an authentication navigation observer. AuthPageGate records
whether each built route contains an already allowlisted public auth destination.
On session loss, if the current page is public, the observer retains public pages
and their existing state while removing private history and all unclassified
dialogs. If the current page is private or unknown, the existing login reset
continues. The observer is scoped to the actual Navigator instance.

No additional destination becomes public. Backend session, role, ownership, OTP,
and profile-completion checks remain in force. No query/schema/grant changes are
required. An observer that is not installed fails back to the existing login
reset; route names and client-supplied arguments do not classify public pages.

Local regression coverage models session loss during the first rider Continue,
checks that the same form survives and opens OTP, and verifies that cancelling
OTP retains the entered email. It also covers private dialog/history cleanup
above public signup and above private content, plus existing OTP continuation,
logout, account handoff and authentication boundary tests. This models the
session event locally; hosted signup and the reported phone flow still need
device confirmation after rebuilding the app.

Verification: all 20 tests across rider signup session navigation, signup OTP
continuation, authentication boundaries, account handoff and selected-account
login passed. Formatting and whitespace checks passed. The four application
sources have 142, 77, 76 and 49 physical lines; no prohibited inline style
constructors were found in them.
Targeted Dart analysis completed with no issues.
