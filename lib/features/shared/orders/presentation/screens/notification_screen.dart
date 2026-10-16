import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_load_state.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_layout.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/notification_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_content_widgets.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_approval_alert.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_feed.dart';

part 'notification_screen_actions.dart';
part 'notification_screen_views.dart';

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
  late final PageController _pageController;

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? NotificationController();
    _updates = Listenable.merge([_orderController, _controller]);
    _pageController = PageController(
      initialPage: NotificationFilter.values.indexOf(_filter),
    );
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
    _pageController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _selectFilter(NotificationFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    final targetIndex = NotificationFilter.values.indexOf(filter);
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round();
      if (currentPage != targetIndex) {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (index >= 0 && index < NotificationFilter.values.length) {
      final newFilter = NotificationFilter.values[index];
      if (_filter != newFilter) {
        setState(() => _filter = newFilter);
      }
    }
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
          return NotificationLayout(
            header: [
              NotificationHeader(unreadCount: unreadCount),
              NotificationFilterTabs(
                selected: _filter,
                onSelected: _selectFilter,
              ),
              OrderUpdatesBar(
                unreadCount: unreadCount,
                onReadAll: () => _markAllRead(notifications),
                onClearAll: notifications.isEmpty
                    ? null
                    : () => _confirmClearAll(notifications),
              ),
            ],
            body: _content(notifications, loadState),
          );
        },
      ),
    );
  }
}
