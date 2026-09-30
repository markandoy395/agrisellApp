part of 'rider_profile_screen.dart';

extension _RiderProfileLogout on _RiderProfileScreenState {
  void _open(Widget screen) {
    Navigator.of(context).push(agrisellPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _openSafety() async {
    final profile = _profile;
    if (profile == null) return;
    await showAppSafetySheet(
      context: context,
      role: 'rider',
      userName: profile.fullName,
      userContact: profile.contactNumber,
      userEmail: profile.email,
    );
  }

  void _openIncidentHistory() {
    final profile = _profile;
    if (profile == null) return;
    _open(
      IncidentTrackingScreen(
        role: 'rider',
        userName: profile.fullName,
        userContact: profile.contactNumber,
        userEmail: profile.email,
      ),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _logout() async {
    if (!await _canLeaveAccount(RiderAccountExitAction.logout)) return;
    if (mounted) await AccountSessionNavigation.logout(context);
  }

  Future<void> _switchAccount() async {
    if (!await _canLeaveAccount(RiderAccountExitAction.switchAccount)) return;
    if (mounted) await AccountSessionNavigation.openSwitcher(context);
  }

  Future<bool> _canLeaveAccount(RiderAccountExitAction action) async {
    final synchronized = await RiderAccountExitPolicy.prepare(
      action,
      prepareForLogout: widget.prepareForLogout,
    );
    if (!synchronized && mounted) {
      _message(
        'Availability could not be synchronized. Reconnect before continuing.',
      );
    }
    return synchronized;
  }
}
