import 'package:flutter/material.dart';
import 'chat_skeleton_items.dart';

class ChatLoadingSkeleton extends StatefulWidget {
  const ChatLoadingSkeleton({this.conversations = true, super.key});
  final bool conversations;

  @override
  State<ChatLoadingSkeleton> createState() => _ChatLoadingSkeletonState();
}

class _ChatLoadingSkeletonState extends State<ChatLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: 0.55,
    upperBound: 1,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.conversations ? 'Loading conversations' : 'Loading messages',
    child: ExcludeSemantics(
      child: FadeTransition(
        opacity: _controller,
        child: ListView.separated(
          padding: widget.conversations
              ? const EdgeInsets.only(top: 4, bottom: 12)
              : const EdgeInsets.fromLTRB(14, 14, 14, 12),
          itemCount: widget.conversations ? 7 : 6,
          separatorBuilder: (_, _) =>
              SizedBox(height: widget.conversations ? 0 : 14),
          itemBuilder: (_, index) => widget.conversations
              ? const ChatConversationSkeletonItem()
              : ChatMessageSkeletonItem(own: index.isOdd),
        ),
      ),
    ),
  );
}
