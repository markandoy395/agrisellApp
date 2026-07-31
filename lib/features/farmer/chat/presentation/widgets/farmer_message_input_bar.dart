import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerMessageInputBar extends StatelessWidget {
  const FarmerMessageInputBar({
    required this.bottomClearance,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    super.key,
  });

  final double bottomClearance;
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = keyboardInset > 0 ? 12.0 : bottomClearance;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 9, 12, bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                maxLength: 1000,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type a reply',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  border: _inputBorder(AgrisellColors.borderLine),
                  enabledBorder: _inputBorder(AgrisellColors.borderLine),
                  focusedBorder: _inputBorder(AgrisellColors.authGreen),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton.filled(
                onPressed: isSending ? null : onSend,
                icon: const Icon(Icons.send_rounded, size: 19),
                tooltip: 'Send message',
                style: IconButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  disabledBackgroundColor: AgrisellColors.mutedText,
                  foregroundColor: AgrisellColors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color),
    );
  }
}
