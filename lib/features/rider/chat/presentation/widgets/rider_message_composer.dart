import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled && !widget.isSending,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Write a delivery message',
                  hintStyle: const TextStyle(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AgrisellColors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                style: IconButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  foregroundColor: AgrisellColors.surface,
                ),
                icon: widget.isSending
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AgrisellColors.surface,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
