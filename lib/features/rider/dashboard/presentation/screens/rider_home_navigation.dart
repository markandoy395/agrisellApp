part of 'rider_home_screen.dart';

extension _RiderHomeNavigation on _RiderHomeScreenState {
  Future<void> _selectTab(int index) async {
    if (index == _activeIndex) return;
    _setActiveIndex(index);
    _pageController.jumpToPage(index);
  }

  void _openNotifications() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderNotificationsScreen(
          riderId: _riderId ?? '',
          onNotificationAction: (action) =>
              unawaited(_openNotificationAction(action)),
        ),
      ),
    );
  }

  Future<void> _openNotificationAction(RiderNotificationAction action) async {
    if (!mounted) return;
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    switch (action.destination) {
      case RiderNotificationDestination.delivery ||
          RiderNotificationDestination.report:
        final request = _deliveryController.requests
            .where((item) => item.id == action.deliveryId)
            .firstOrNull;
        if (request == null) {
          await _selectTab(RiderHomeScreen.deliveriesNavIndex);
          return;
        }
        await Navigator.of(context).push(
          agrisellPageRoute<void>(
            builder: (_) => RiderDeliveryDetailsScreen(
              request: request,
              controller: _deliveryController,
              riderId: _riderId ?? '',
              locationController: _locationController,
              onOpenConversation: _openDeliveryConversation,
            ),
          ),
        );
        return;
      case RiderNotificationDestination.conversation:
        final conversation = _messagesController.conversations
            .where((item) => item.id == action.conversationId)
            .firstOrNull;
        if (conversation == null) {
          await _selectTab(RiderHomeScreen.messagesNavIndex);
          return;
        }
        await _messagesController.selectConversation(conversation);
        if (!mounted) return;
        await Navigator.of(context).push(
          agrisellPageRoute<void>(
            builder: (_) => RiderConversationPanel(
              controller: _messagesController,
              quickReplies: RiderQuickReply.defaults,
              onAttachmentRequested: _captureCommunicationAttachment,
            ),
          ),
        );
        _messagesController.closeConversation();
        return;
      case RiderNotificationDestination.earnings:
        _openEarnings();
        return;
      case RiderNotificationDestination.none:
        return;
    }
  }

  Future<bool> _openDeliveryConversation(String deliveryId) async {
    final conversation = _messagesController.conversations
        .where((item) => item.deliveryId == deliveryId)
        .firstOrNull;
    if (conversation == null) return false;
    await _messagesController.selectConversation(conversation);
    if (!mounted) return false;
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderConversationPanel(
          controller: _messagesController,
          quickReplies: RiderQuickReply.defaults,
          onAttachmentRequested: _captureCommunicationAttachment,
        ),
      ),
    );
    _messagesController.closeConversation();
    return true;
  }
}
