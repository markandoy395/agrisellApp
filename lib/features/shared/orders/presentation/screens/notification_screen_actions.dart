part of 'notification_screen.dart';

extension _NotificationScreenActions on _NotificationScreenState {
  void _reportUnreadCount(int count) {
    if (_lastReportedUnreadCount == count) return;
    _lastReportedUnreadCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _lastReportedUnreadCount == count) {
        widget.onUnreadCountChanged?.call(count);
      }
    });
  }

  void _watchDatabaseNotifications() {
    if (widget.notifications != null) return;
    _updateUi(() {
      _repositoryLoadState = NotificationLoadState.loading;
      _repositoryError = null;
    });
    _notificationSubscription = _repository
        .watchForUser(widget.userId)
        .listen(
          _receiveDatabaseNotifications,
          onError: (Object error) {
            if (!mounted) return;
            _updateUi(() {
              _repositoryLoadState = NotificationLoadState.error;
              _repositoryError = error
                  .toString()
                  .replaceFirst('Exception: ', '')
                  .trim();
            });
          },
        );
  }

  void _receiveDatabaseNotifications(List<HomeNotification> notifications) {
    if (!mounted) return;
    _updateUi(() {
      _databaseNotifications = notifications;
      _repositoryLoadState = NotificationLoadState.ready;
      _repositoryError = null;
    });
    final approval = _repository.firstUnreadFarmerApproval(notifications);
    if (approval == null || !_shownApprovalIds.add(approval.id)) return;
    unawaited(showFarmerApprovalAlert(context, _repository, notifications));
  }

  void _retryDatabaseNotifications() {
    unawaited(_notificationSubscription?.cancel());
    _notificationSubscription = null;
    _watchDatabaseNotifications();
  }

  void _open(HomeNotification notification) {
    _controller.markRead(notification);
    _persistRead(notification, isRead: true);
    widget.onNotificationSelected?.call(notification);
  }

  void _toggleRead(HomeNotification notification) {
    final wasRead = _controller.isRead(notification);
    wasRead
        ? _controller.markUnread(notification)
        : _controller.markRead(notification);
    _persistRead(notification, isRead: !wasRead);
  }

  void _persistRead(HomeNotification notification, {required bool isRead}) {
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;
    unawaited(_repository.setRead(userId, notification.id, isRead: isRead));
  }

  void _delete(HomeNotification notification) {
    _controller.delete(notification);
    final userId = widget.userId;
    if (userId != null && userId.isNotEmpty) {
      unawaited(_repository.delete(userId, notification.id));
    }
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(const SnackBar(content: Text('Notification deleted.')));
  }

  void _markAllRead(List<HomeNotification> notifications) {
    _controller.markAllRead(notifications);
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;
    unawaited(_repository.markAllRead(userId, notifications));
  }

  Future<void> _confirmClearAll(List<HomeNotification> notifications) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This removes all notifications from your feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _controller.clear(notifications);
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;
    unawaited(_repository.deleteAll(userId, notifications));
  }
}
