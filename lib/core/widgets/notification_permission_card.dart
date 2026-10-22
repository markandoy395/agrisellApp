import 'dart:async';
import 'package:flutter/material.dart';
import 'app_snack_bar.dart';
import '../services/notification_permission_gateway.dart';
import '../theme/notification_permission_styles.dart';
import 'notification_permission_benefit.dart';
import 'notification_permission_prompt.dart';

class NotificationPermissionCard extends StatefulWidget {
  const NotificationPermissionCard({
    required this.benefit,
    this.gateway,
    this.onEnabled,
    super.key,
  });
  final NotificationPermissionBenefit benefit;
  final NotificationPermissionGateway? gateway;
  final Future<void> Function()? onEnabled;

  @override
  State<NotificationPermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<NotificationPermissionCard>
    with WidgetsBindingObserver {
  NotificationPermissionState _state = NotificationPermissionState.unavailable;
  bool _busy = false;
  NotificationPermissionGateway get _gateway =>
      widget.gateway ?? DeviceNotificationPermissionGateway.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    try {
      final state = await _gateway.read();
      if (state == NotificationPermissionState.enabled &&
          _state != NotificationPermissionState.enabled) {
        await (widget.onEnabled ??
            NotificationPermissionPrompt.registerCurrentUser)();
      }
      if (mounted) setState(() => _state = state);
    } on Object {
      // Do not hide the in-app notification feed when push is unavailable.
    }
  }

  Future<void> _open() async {
    setState(() => _busy = true);
    try {
      if (_state == NotificationPermissionState.blocked) {
        if (!await _gateway.openSettings()) {
          throw StateError('settings_unavailable');
        }
      } else {
        await NotificationPermissionPrompt.offer(
          context,
          benefit: widget.benefit,
          gateway: _gateway,
          automatic: false,
          onEnabled: () async {
            if (mounted) {
              setState(() => _state = NotificationPermissionState.enabled);
            }
            await (widget.onEnabled ??
                NotificationPermissionPrompt.registerCurrentUser)();
          },
        );
      }
      await _refresh();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showAppSnackBar(
          const SnackBar(
            content: Text(
              'Open device Settings > Apps > AgriSell > Notifications.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == NotificationPermissionState.unavailable ||
        _state == NotificationPermissionState.enabled) {
      return const SizedBox.shrink();
    }
    final blocked = _state == NotificationPermissionState.blocked;
    return Card(
      margin: NotificationPermissionStyles.margin,
      child: Padding(
        padding: NotificationPermissionStyles.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blocked ? 'Notifications are off' : widget.benefit.title,
              style: NotificationPermissionStyles.title,
            ),
            const SizedBox(height: 8),
            Text(
              widget.benefit.message,
              style: NotificationPermissionStyles.message,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _busy ? null : _open,
              icon: Icon(
                blocked
                    ? Icons.settings_outlined
                    : Icons.notifications_outlined,
              ),
              label: Text(blocked ? 'Open Settings' : 'Turn on notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
