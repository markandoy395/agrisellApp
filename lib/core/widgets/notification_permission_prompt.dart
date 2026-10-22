import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_permission_gateway.dart';
import '../services/push_notification_service.dart';
import '../../features/auth/data/auth_session_service.dart';
import 'notification_permission_benefit.dart';

abstract final class NotificationPermissionPrompt {
  static bool _showing = false;

  static Future<void> offer(
    BuildContext context, {
    required NotificationPermissionBenefit benefit,
    bool automatic = true,
    NotificationPermissionGateway? gateway,
    Future<void> Function()? onEnabled,
  }) async {
    if (_showing) return;
    _showing = true;
    final device = gateway ?? DeviceNotificationPermissionGateway.instance;
    try {
      final state = await device.read();
      if (state == NotificationPermissionState.unavailable ||
          state == NotificationPermissionState.enabled)
        return;
      if (automatic && await device.hasOffered()) return;
      if (!context.mounted) return;
      await device.markOffered();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PermissionDialog(
          benefit: benefit,
          gateway: device,
          initialState: state,
          onEnabled: onEnabled ?? registerCurrentUser,
        ),
      );
    } on Object {
      // Optional alerts must never interrupt a completed order or publication.
    } finally {
      _showing = false;
    }
  }

  static Future<void> registerCurrentUser() async {
    final session = AuthSessionService.instance;
    if (session.isAuthenticated) {
      await PushNotificationService.instance.registerForUser(
        session.currentAccount?.id,
      );
    }
  }
}

class _PermissionDialog extends StatefulWidget {
  const _PermissionDialog({
    required this.benefit,
    required this.gateway,
    required this.initialState,
    required this.onEnabled,
  });
  final NotificationPermissionBenefit benefit;
  final NotificationPermissionGateway gateway;
  final NotificationPermissionState initialState;
  final Future<void> Function() onEnabled;

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog>
    with WidgetsBindingObserver {
  late var _state = widget.initialState;
  bool _busy = false;
  bool _settingsOpened = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _settingsOpened) {
      _settingsOpened = false;
      unawaited(_checkSettings());
    }
  }

  Future<void> _checkSettings() async {
    try {
      if (await widget.gateway.read() == NotificationPermissionState.enabled) {
        await widget.onEnabled();
        if (mounted) Navigator.of(context).pop();
      }
    } on Object {
      if (mounted)
        setState(
          () => _error = 'Could not check notifications. Please try again.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _state == NotificationPermissionState.blocked;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.notifications_active_outlined),
        title: Text(blocked ? 'Notifications are off' : widget.benefit.title),
        content: Text(
          _error ??
              (blocked
                  ? '${widget.benefit.message} Open notification settings to turn them on.'
                  : widget.benefit.message),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(blocked ? 'Close' : 'Not now'),
          ),
          FilledButton(
            onPressed: _busy ? null : _enable,
            child: Text(
              _busy
                  ? 'Please wait…'
                  : blocked
                  ? 'Open Settings'
                  : 'Turn on',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enable() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_state == NotificationPermissionState.blocked) {
        final opened = await widget.gateway.openSettings();
        if (!mounted) return;
        if (opened) {
          _settingsOpened = true;
        } else {
          setState(
            () => _error =
                'Could not open Settings. Open your device Settings, then Apps > AgriSell > Notifications.',
          );
        }
      } else {
        final state = await widget.gateway.request();
        if (!mounted) return;
        setState(() => _state = state);
        if (state == NotificationPermissionState.enabled) {
          await widget.onEnabled();
          if (mounted) Navigator.of(context).pop();
        }
      }
    } on Object {
      if (mounted)
        setState(
          () => _error = 'Could not update notifications. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
