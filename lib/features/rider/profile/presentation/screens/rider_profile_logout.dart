part of 'rider_profile_screen.dart';

extension _RiderProfileLogout on _RiderProfileScreenState {
  void _open(Widget screen) {
    Navigator.of(context).push(agrisellPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _openSafety() async {
    final profile = _profile;
    if (profile == null) return;
    final type = await showRiderSafetySheet(context);
    if (type == null || !mounted) return;
    final reason = await showRiderSafetyReasonDialog(context, type);
    if (type.requiresReason && reason == null) return;
    final sent = await _safety.submit(
      riderId: profile.id,
      type: type,
      reason: reason,
    );
    if (!mounted) return;
    _message(sent ? '${type.label} sent to support.' : _safety.errorMessage!);
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _logout() async {
    if (!await _canLeaveAccount()) return;
    if (mounted) await AccountSessionNavigation.logout(context);
  }

  Future<void> _switchAccount() async {
    if (!await _canLeaveAccount()) return;
    if (mounted) await AccountSessionNavigation.openSwitcher(context);
  }

  Future<bool> _canLeaveAccount() async {
    final synchronized = await widget.prepareForLogout?.call() ?? true;
    if (!synchronized && mounted) {
      _message(
        'Availability could not be synchronized. Reconnect before continuing.',
      );
    }
    return synchronized;
  }
}
