import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_message_composer_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_field.dart';
import 'package:agresell_app/features/shared/chat/domain/chat_limits.dart';

class RiderMessageComposer extends StatefulWidget {
  const RiderMessageComposer({
    required this.enabled,
    required this.isSending,
    required this.onSend,
    super.key,
  });
  final bool enabled;
  final bool isSending;
  final Future<bool> Function(String message) onSend;
  @override
  State<RiderMessageComposer> createState() => _RiderMessageComposerState();
}

class _RiderMessageComposerState extends State<RiderMessageComposer> {
  final _controller = TextEditingController();
  var _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _controller.text;
    if (!ChatLimits.valid(message) ||
        _sending ||
        widget.isSending ||
        !widget.enabled)
      return;
    setState(() => _sending = true);
    try {
      final sent = await widget.onSend(message);
      if (sent && mounted && _controller.text == message) _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: RiderMessageComposerStyles.container,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ChatMessageField(
                controller: _controller,
                enabled: widget.enabled && !widget.isSending && !_sending,
                minLines: 1,
                maxLines: 3,
                decoration: RiderMessageComposerStyles.inputDecoration,
                onSend: _send,
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => IconButton.filled(
                tooltip: 'Send message',
                onPressed:
                    widget.enabled &&
                        !widget.isSending &&
                        !_sending &&
                        ChatLimits.valid(value.text)
                    ? _send
                    : null,
                style: RiderMessageComposerStyles.iconButtonStyle,
                icon: widget.isSending || _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AgrisellColors.surface,
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 22),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
