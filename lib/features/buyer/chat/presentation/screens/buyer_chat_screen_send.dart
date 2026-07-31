part of 'buyer_chat_screen.dart';

extension _BuyerChatScreenSend on _BuyerChatScreenState {
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || text.length > 1000) return;
    _messageController.clear();
    unawaited(_scrollAfterFrame());
    final sent = await widget.controller.sendMessage(widget.thread.id, text);
    await _scrollAfterFrame();
    if (!mounted || sent) return;
    final error =
        widget.controller.messageErrorFor(widget.thread.id) ??
        'Your message was not sent. Tap the message to retry.';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _scrollAfterFrame() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }
}
