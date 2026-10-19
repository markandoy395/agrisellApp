import 'package:flutter/material.dart';
import '../styles/chat_loading_skeleton_styles.dart';

class ChatConversationSkeletonItem extends StatelessWidget {
  const ChatConversationSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    key: ValueKey('conversation-skeleton-row'),
    decoration: ChatLoadingSkeletonStyles.row,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: DecoratedBox(decoration: ChatLoadingSkeletonStyles.avatar),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _Line(width: 0.7, height: 14)),
                    SizedBox(width: 12),
                    SizedBox(width: 36, child: _Line(width: 1, height: 10)),
                  ],
                ),
                SizedBox(height: 8),
                _Line(width: 0.9, height: 11),
                SizedBox(height: 5),
                _Line(width: 0.55, height: 11),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ChatMessageSkeletonItem extends StatelessWidget {
  const ChatMessageSkeletonItem({required this.own, super.key});
  final bool own;

  @override
  Widget build(BuildContext context) => Align(
    alignment: own ? Alignment.centerRight : Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: own ? 0.65 : 0.75,
      child: DecoratedBox(
        key: const ValueKey('message-skeleton-bubble'),
        decoration: ChatLoadingSkeletonStyles.bubble(own),
        child: const SizedBox(height: 64),
      ),
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: width,
    child: SizedBox(
      height: height,
      child: const DecoratedBox(decoration: ChatLoadingSkeletonStyles.block),
    ),
  );
}
