import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/chat/presentation/styles/rider_message_composer_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_reference_styles.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class RiderMessageComposer extends StatefulWidget {
  const RiderMessageComposer({
    required this.enabled,
    required this.isSending,
    required this.onSend,
    this.onAttach,
    super.key,
  });

  final VoidCallback? onAttach;
  final bool enabled;
  final bool isSending;
  final Future<bool> Function(String message) onSend;

  @override
  State<RiderMessageComposer> createState() => _RiderMessageComposerState();
}

class _RiderMessageComposerState extends State<RiderMessageComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _controller.text;
    if (message.trim().isEmpty || widget.isSending || !widget.enabled) return;
    final sent = await widget.onSend(message);
    if (sent && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ChatReferenceStyles.composerDecoration,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Row(
            children: [
              if (widget.onAttach != null)
                IconButton(
                  tooltip: 'Attach photo',
                  onPressed: widget.enabled ? widget.onAttach : null,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: ChatReferenceStyles.teal,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled && !widget.isSending,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: SharedPresentationStyles.body,
                  decoration: RiderMessageComposerStyles.inputDecoration,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Send message',
                child: IconButton.filled(
                  tooltip: 'Send message',
                  onPressed: widget.enabled && !widget.isSending ? _send : null,
                  style: RiderMessageComposerStyles.iconButtonStyle,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AgrisellColors.surface,
                          ),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
