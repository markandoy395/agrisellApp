import 'package:flutter/material.dart';
import '../../domain/rider_communication_models.dart';
import '../styles/rider_messaging_design_styles.dart';

Future<String?> showRiderQuickReplies(
  BuildContext context,
  List<RiderQuickReply> replies,
) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: .9,
      child: _QuickRepliesSheet(replies: replies),
    ),
  );
}

class _QuickRepliesSheet extends StatefulWidget {
  const _QuickRepliesSheet({required this.replies});
  final List<RiderQuickReply> replies;
  @override
  State<_QuickRepliesSheet> createState() => _QuickRepliesSheetState();
}

class _QuickRepliesSheetState extends State<_QuickRepliesSheet> {
  var _selected = 0;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick replies',
                  style: RiderMessagingDesignStyles.heading,
                ),
              ),
              IconButton(
                tooltip: 'Close quick replies',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            'Choose a phrase, then send your text reply.',
            style: RiderMessagingDesignStyles.muted,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var index = 0; index < widget.replies.length; index++)
                      SizedBox(
                        width: (constraints.maxWidth - 10) / 2,
                        child: OutlinedButton.icon(
                          style: index == _selected
                              ? RiderMessagingDesignStyles.selectedReplyButton
                              : RiderMessagingDesignStyles.replyButton,
                          onPressed: () => setState(() => _selected = index),
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                          ),
                          label: Text(widget.replies[index].label),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: RiderMessagingDesignStyles.protected,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected message',
                  style: RiderMessagingDesignStyles.caption,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.replies[_selected].message,
                  style: RiderMessagingDesignStyles.title,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: RiderMessagingDesignStyles.sendButton,
            onPressed: () =>
                Navigator.pop(context, widget.replies[_selected].message),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Send quick reply'),
          ),
        ],
      ),
    ),
  );
}

class RiderTextQuickReplies extends StatelessWidget {
  const RiderTextQuickReplies({
    required this.replies,
    required this.enabled,
    required this.onSend,
    super.key,
  });
  final List<RiderQuickReply> replies;
  final bool enabled;
  final Future<bool> Function(String) onSend;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Row(
      children: [
        for (final reply in [
          ...replies.take(2),
          const RiderQuickReply(label: "I'm outside", message: "I'm outside."),
        ]) ...[
          OutlinedButton(
            style: RiderMessagingDesignStyles.quickButton,
            onPressed: enabled ? () => onSend(reply.message) : null,
            child: Text(reply.label),
          ),
          const SizedBox(width: 8),
        ],
        OutlinedButton.icon(
          style: RiderMessagingDesignStyles.quickButton,
          onPressed: enabled
              ? () async {
                  final message = await showRiderQuickReplies(context, [
                    ...replies,
                    const RiderQuickReply(
                      label: "I'm outside",
                      message: "I'm outside.",
                    ),
                  ]);
                  if (context.mounted && message != null) await onSend(message);
                }
              : null,
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: const Text('Quick replies'),
        ),
      ],
    ),
  );
}
