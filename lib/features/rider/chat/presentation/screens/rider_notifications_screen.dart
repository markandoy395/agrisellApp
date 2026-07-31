import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_state.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_notifications_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/rider_notification_presentation.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_actions.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_list.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';

class RiderNotificationsScreen extends StatefulWidget {
  const RiderNotificationsScreen({
    this.riderId = '',
    this.controller,
    this.onNotificationOpened,
    this.onNotificationAction,
    super.key,
  });

  final String riderId;
  final RiderNotificationsController? controller;
  final ValueChanged<RiderNotification>? onNotificationOpened;
  final ValueChanged<RiderNotificationAction>? onNotificationAction;

  @override
  State<RiderNotificationsScreen> createState() =>
      _RiderNotificationsScreenState();
}

class _RiderNotificationsScreenState extends State<RiderNotificationsScreen> {
  late final RiderNotificationsController _controller;
  late final bool _ownsController;
  var _filter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderNotificationsController();
    unawaited(_controller.load(riderId: widget.riderId));
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        children: [
          RiderPageHeader(
            title: 'Notifications',
            subtitle: _controller.unreadCount == 0
                ? 'You are all caught up'
                : '${_controller.unreadCount} unread updates',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.unreadCount > 0)
                  IconButton(
                    tooltip: 'Mark all as read',
                    onPressed: _markAllRead,
                    icon: const Icon(Icons.done_all_rounded),
                    color: AgrisellColors.surface,
                  ),
                if (_controller.notifications.any((item) => item.canDelete))
                  IconButton(
                    tooltip: 'Clear all notifications',
                    onPressed: _confirmClearAll,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    color: AgrisellColors.surface,
                  ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AgrisellColors.surface,
                ),
              ],
            ),
          ),
          NotificationFilterTabs(
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          Expanded(child: _content()),
        ],
      ),
    ),
  );

  Widget _content() {
    return switch (_controller.state) {
      RiderCommunicationLoadState.loading => const NotificationStateView(
        icon: Icons.sync_rounded,
        title: 'Loading notifications',
        message: 'Retrieving your delivery and account updates.',
        isLoading: true,
      ),
      RiderCommunicationLoadState.offline => NotificationStateView(
        icon: Icons.wifi_off_rounded,
        title: 'You are offline',
        message: 'Reconnect to receive delivery and account updates.',
        actionLabel: 'Try again',
        onAction: () => unawaited(_controller.load(riderId: widget.riderId)),
      ),
      RiderCommunicationLoadState.error => NotificationStateView(
        icon: Icons.error_outline_rounded,
        title: 'Notifications unavailable',
        message: _controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try again',
        onAction: () => unawaited(_controller.load(riderId: widget.riderId)),
      ),
      RiderCommunicationLoadState.ready => _readyContent(),
    };
  }

  Widget _readyContent() {
    final items = _controller.notifications
        .where((item) => _filter.includes(item.type.category))
        .toList(growable: false);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: RiderNotificationList(
        key: ValueKey(
          '${_filter.name}:${items.map((item) => item.id).join('|')}',
        ),
        notifications: items,
        onOpen: _openNotification,
        onToggleRead: _toggleRead,
        onDelete: _deleteNotification,
      ),
    );
  }

  Future<void> _openNotification(RiderNotification notification) async {
    if (!notification.isRead) await _controller.markRead(notification.id);
    if (!mounted) return;
    widget.onNotificationOpened?.call(notification);
    widget.onNotificationAction?.call(
      RiderNotificationAction.fromNotification(notification),
    );
  }

  void _toggleRead(RiderNotification notification) {
    notification.isRead
        ? unawaited(_controller.markUnread(notification.id))
        : unawaited(_controller.markRead(notification.id));
  }

  Future<void> _deleteNotification(RiderNotification notification) async {
    await _controller.delete(notification.id);
    _showActionError();
  }

  Future<void> _markAllRead() async {
    await _controller.markAllRead();
    _showActionError();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await confirmClearRiderNotifications(context);
    if (confirmed) await _controller.clearAll();
    _showActionError();
  }

  void _showActionError() {
    if (!mounted || _controller.actionError == null) return;
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(_controller.actionError!)));
  }
}
