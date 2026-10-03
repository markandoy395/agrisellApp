part of 'notification_screen.dart';

extension _NotificationScreenViews on _NotificationScreenState {
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
      NotificationLoadState.ready => PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: NotificationFilter.values.length,
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          return NotificationFeed(
            key: ValueKey(filter),
            notifications: notifications,
            filter: filter,
            controller: _controller,
            onOpen: _open,
            onToggleRead: _toggleRead,
            onDelete: _delete,
          );
        },
      ),
    };
  }

  VoidCallback? get _retryAction {
    if (widget.onRetry case final retry?) return retry;
    if (widget.notifications != null || widget.loadState != null) return null;
    return _retryDatabaseNotifications;
  }
}
