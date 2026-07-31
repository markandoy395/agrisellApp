import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_chat_screen.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_conversation_start_failure.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_message_inbox.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository_factory.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

part 'buyer_message_screen_refresh.dart';

class BuyerMessageScreen extends StatefulWidget {
  const BuyerMessageScreen({
    this.isActive = true,
    this.repository,
    this.initialConversation,
    this.onExit,
    this.onUnreadCountChanged,
    this.chatBottomPadding = 96,
    this.autoRefreshInterval = const Duration(seconds: 15),
    super.key,
  });

  final bool isActive;
  final MarketplaceMessagingRepository? repository;
  final MarketplaceConversationSeed? initialConversation;
  final VoidCallback? onExit;
  final ValueChanged<int>? onUnreadCountChanged;
  final double chatBottomPadding;
  final Duration autoRefreshInterval;

  @override
  State<BuyerMessageScreen> createState() => _BuyerMessageScreenState();
}

class _BuyerMessageScreenState extends State<BuyerMessageScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _searchController;
  late final MarketplaceMessagingController _controller;
  MarketplaceConversation? _selectedThread;
  bool _seedFailed = false;
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
      actorRole: MarketplaceActorRole.buyer,
    )..addListener(_onControllerChanged);
    unawaited(_initialize());
    _syncRefreshTimer();
  }

  Future<void> _initialize() async {
    final seed = widget.initialConversation;
    if (seed == null) {
      await _controller.load();
      return;
    }
    await _openSeed(seed);
  }

  Future<void> _openSeed(MarketplaceConversationSeed seed) async {
    setState(() => _seedFailed = false);
    final conversation = await _controller.startConversation(seed);
    if (!mounted) return;
    if (conversation == null) {
      setState(() => _seedFailed = true);
      return;
    }
    setState(() => _selectedThread = conversation);
    await _controller.openConversation(conversation.id, refresh: true);
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
  void didUpdateWidget(covariant BuyerMessageScreen oldWidget) {
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

  List<MarketplaceConversation> get _visibleThreads {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _controller.conversations;
    return _controller.conversations
        .where((thread) {
          return thread.farmerName.toLowerCase().contains(query) ||
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

  void _backFromChat() {
    if (widget.initialConversation != null && widget.onExit != null) {
      widget.onExit!();
      return;
    }
    setState(() => _selectedThread = null);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedThread;
    return PopScope<void>(
      canPop: widget.onExit != null || !widget.isActive || selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selected != null) _backFromChat();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _seedFailed
            ? BuyerConversationStartFailure(
                sellerName: widget.initialConversation!.sellerName,
                onRetry: () => _openSeed(widget.initialConversation!),
                onBack: widget.onExit,
              )
            : selected == null
            ? BuyerMessageInbox(
                key: const ValueKey('buyer-message-inbox'),
                searchController: _searchController,
                threads: _visibleThreads,
                state: _controller.state,
                hasQuery: _query.trim().isNotEmpty,
                onQueryChanged: (value) => setState(() => _query = value),
                onThreadSelected: _openThread,
                onRetry: _controller.load,
              )
            : BuyerChatScreen(
                key: ValueKey('buyer-chat-${selected.id}'),
                thread: selected,
                controller: _controller,
                onBack: _backFromChat,
                bottomPadding: widget.chatBottomPadding,
              ),
      ),
    );
  }
}
