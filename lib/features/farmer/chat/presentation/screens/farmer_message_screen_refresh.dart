part of 'farmer_message_screen.dart';

extension _FarmerMessageScreenRefresh on _FarmerMessageScreenState {
  void _syncRefreshTimer() {
    _stopAutoRefresh();
    if (!widget.isActive || widget.autoRefreshInterval <= Duration.zero) return;
    _refreshTimer = Timer.periodic(
      widget.autoRefreshInterval,
      (_) => unawaited(_refresh()),
    );
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _handleWidgetUpdate(FarmerMessageScreen oldWidget) {
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.autoRefreshInterval != widget.autoRefreshInterval) {
      _syncRefreshTimer();
    }
    if (!oldWidget.isActive && widget.isActive) unawaited(_refresh());
  }

  void _handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncRefreshTimer();
      if (widget.isActive) unawaited(_refresh());
    } else {
      _stopAutoRefresh();
    }
  }

  Future<void> _refresh() async {
    if (_refreshInProgress || !widget.isActive) return;
    _refreshInProgress = true;
    try {
      await _controller.load(silent: true);
      final selected = _selectedThread;
      if (selected == null) return;
      await _controller.openConversation(selected.id, refresh: true);
      if (!mounted) return;
      final fresh = _controller.conversations
          .where((item) => item.id == selected.id)
          .firstOrNull;
      if (fresh != null) {
        _selectedThread = fresh;
        _onControllerChanged();
      }
    } finally {
      _refreshInProgress = false;
    }
  }
}
