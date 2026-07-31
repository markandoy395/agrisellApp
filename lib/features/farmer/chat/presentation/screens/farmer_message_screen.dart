import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_chat_detail_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_inbox.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository_factory.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

part 'farmer_message_screen_refresh.dart';

class FarmerMessageScreen extends StatefulWidget {
  const FarmerMessageScreen({
    this.isActive = true,
    this.repository,
    this.onUnreadCountChanged,
    this.autoRefreshInterval = const Duration(seconds: 15),
    super.key,
  });

  final bool isActive;
  final MarketplaceMessagingRepository? repository;
  final ValueChanged<int>? onUnreadCountChanged;
  final Duration autoRefreshInterval;

  @override
  State<FarmerMessageScreen> createState() => _FarmerMessageScreenState();
}

class _FarmerMessageScreenState extends State<FarmerMessageScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _searchController;
  late final MarketplaceMessagingController _controller;
  var _activeFilter = FarmerMessageFilter.all;
  MarketplaceConversation? _selectedThread;
  int _lastUnreadCount = -1;
  Timer? _refreshTimer;
  bool _refreshInProgress = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController = TextEditingController();
    _controller = MarketplaceMessagingController(
      repository: widget.repository ?? currentMarketplaceMessagingRepository(),
      actorRole: MarketplaceActorRole.farmer,
    )..addListener(_onControllerChanged);
    unawaited(_controller.load());
    _syncRefreshTimer();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleUnreadCount();
  }

  void _scheduleUnreadCount() {
    if (_controller.state != MarketplaceMessagingLoadState.ready) return;
    final count = _controller.conversations.fold(
      0,
      (total, thread) => total + thread.unreadCount,
    );
    if (count == _lastUnreadCount) return;
    _lastUnreadCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onUnreadCountChanged?.call(count);
    });
  }

  @override
  void didUpdateWidget(covariant FarmerMessageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleWidgetUpdate(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleLifecycleChange(state);
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceConversation> get _filteredThreads {
    final query = _query.trim().toLowerCase();
    return _controller.conversations
        .where((thread) {
          final matchesFilter = switch (_activeFilter) {
            FarmerMessageFilter.all => true,
            FarmerMessageFilter.unread => thread.hasUnread,
            FarmerMessageFilter.orders => thread.hasOrderContext,
            FarmerMessageFilter.reserve =>
              !thread.hasOrderContext && thread.hasProductContext,
          };
          if (!matchesFilter || query.isEmpty) return matchesFilter;
          return thread.buyerName.toLowerCase().contains(query) ||
              thread.farmName.toLowerCase().contains(query) ||
              (thread.productName ?? '').toLowerCase().contains(query) ||
              thread.lastMessage.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void _openThread(MarketplaceConversation thread) {
    setState(() => _selectedThread = thread.copyWith(unreadCount: 0));
    unawaited(_controller.openConversation(thread.id));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedThread;
    final bottomClearance = 108.0 + MediaQuery.viewPaddingOf(context).bottom;
    return PopScope<void>(
      canPop: !widget.isActive || selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selected != null) setState(() => _selectedThread = null);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: selected == null
            ? FarmerMessageInbox(
                key: const ValueKey('message-inbox'),
                searchController: _searchController,
                activeFilter: _activeFilter,
                threads: _filteredThreads,
                state: _controller.state,
                onQueryChanged: (value) => setState(() => _query = value),
                onFilterChanged: (filter) {
                  setState(() => _activeFilter = filter);
                },
                onThreadSelected: _openThread,
                onRetry: _controller.load,
              )
            : FarmerChatDetailScreen(
                key: ValueKey('message-detail-${selected.id}'),
                thread: selected,
                controller: _controller,
                bottomClearance: bottomClearance,
                onBack: () => setState(() => _selectedThread = null),
              ),
      ),
    );
  }
}
