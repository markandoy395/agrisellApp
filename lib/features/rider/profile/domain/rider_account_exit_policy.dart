enum RiderAccountExitAction { switchAccount, logout }

abstract final class RiderAccountExitPolicy {
  static Future<bool> prepare(
    RiderAccountExitAction action, {
    Future<bool> Function()? prepareForLogout,
  }) {
    if (action == RiderAccountExitAction.switchAccount) {
      return Future<bool>.value(true);
    }
    return prepareForLogout?.call() ?? Future<bool>.value(true);
  }
}
