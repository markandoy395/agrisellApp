import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_load_state.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/notification_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_content_widgets.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_approval_alert.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_feed.dart';

part 'notification_screen_actions.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    this.role = AuthRole.buyer,
    this.userId,
    this.loadState,
    this.errorMessage,
    this.onRetry,
    this.onNotificationSelected,
    this.onUnreadCountChanged,
    this.controller,
    this.notifications,
    this.repository = const HomeNotificationRepository(),
    super.key,
  });

  final AuthRole role;
  final String? userId;
  final NotificationLoadState? loadState;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<HomeNotification>? onNotificationSelected;
  final ValueChanged<int>? onUnreadCountChanged;
  final NotificationController? controller;
  final List<HomeNotification>? notifications;
  final HomeNotificationRepository repository;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _orderController = OrderController.instance;
  late HomeNotificationRepository _repository;
  late final NotificationController _controller;
  late final Listenable _updates;
  late final bool _ownsController;
  StreamSubscription<List<HomeNotification>>? _notificationSubscription;
  var _databaseNotifications = const <HomeNotification>[];
  var _repositoryLoadState = NotificationLoadState.loading;
  String? _repositoryError;
  final _shownApprovalIds = <String>{};
  var _filter = NotificationFilter.all;
  int? _lastReportedUnreadCount;

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? NotificationController();
    _updates = Listenable.merge([_orderController, _controller]);
    _watchDatabaseNotifications();
  }

  @override
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId == widget.userId &&
        identical(oldWidget.notifications, widget.notifications) &&
        identical(oldWidget.repository, widget.repository)) {
      return;
    }
    _repository = widget.repository;
    unawaited(_notificationSubscription?.cancel());
    _notificationSubscription = null;
    _databaseNotifications = const [];
    _watchDatabaseNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: AnimatedBuilder(
        animation: _updates,
        builder: (context, _) {
          final notifications = _notifications();
          final loadState =
              widget.loadState ??
              (widget.notifications != null
                  ? NotificationLoadState.ready
                  : _repositoryLoadState);
          final unreadCount = notifications
              .where((notification) => !_controller.isRead(notification))
              .length;
          _reportUnreadCount(unreadCount);
          return Column(
            children: [
              NotificationHeader(unreadCount: unreadCount),
              NotificationFilterTabs(
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              OrderUpdatesBar(
                unreadCount: unreadCount,
                onReadAll: () => _markAllRead(notifications),
                onClearAll: notifications.isEmpty
                    ? null
                    : () => _confirmClearAll(notifications),
              ),
              Expanded(child: _content(notifications, loadState)),
            ],
          );
        },
      ),
    );
  }

  List<HomeNotification> _notifications() {
    final source = widget.notifications ?? const <HomeNotification>[];
    final items =
        [
              ..._orderController.orderNotifications,
              ..._databaseNotifications,
              ...source,
            ]
            .where(
              (notification) =>
                  notification.isVisibleTo(
                    widget.role,
                    userId: widget.userId,
                  ) &&
                  !_controller.isDeleted(notification),
            )
            .toList(growable: false);
    items.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return items;
  }

  Widget _content(
    List<HomeNotification> notifications,
    NotificationLoadState loadState,
  ) {
    return switch (loadState) {
      NotificationLoadState.loading => const NotificationStateView(
        icon: Icons.sync_rounded,
        title: 'Loading notifications',
        message: 'Retrieving your latest AgriSell updates.',
        isLoading: true,
      ),
      NotificationLoadState.offline => NotificationStateView(
        icon: Icons.wifi_off_rounded,
        title: 'You are offline',
        message:
            'Reconnect to refresh notifications. Existing updates remain safe.',
        actionLabel: _retryAction == null ? null : 'Try again',
        onAction: _retryAction,
      ),
      NotificationLoadState.error => NotificationStateView(
        icon: Icons.error_outline_rounded,
        title: 'Notifications unavailable',
        message:
            widget.errorMessage ??
            _repositoryError ??
            'Something went wrong. Please try again.',
        actionLabel: _retryAction == null ? null : 'Try again',
        onAction: _retryAction,
      ),
      NotificationLoadState.ready => NotificationFeed(
        notifications: notifications,
        filter: _filter,
        controller: _controller,
        onOpen: _open,
        onToggleRead: _toggleRead,
        onDelete: _delete,
      ),
    };
  }

  VoidCallback? get _retryAction {
    if (widget.onRetry case final retry?) return retry;
    if (widget.notifications != null || widget.loadState != null) return null;
    return _retryDatabaseNotifications;
  }
}
