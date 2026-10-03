import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class SupportTicketComposerStyles {
  static final replyInput = InputDecoration(
    hintText: 'Type your reply here...',
    hintStyle: const TextStyle(fontSize: 14, color: AgrisellColors.mutedText),
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
  );

  static final sendButton = IconButton.styleFrom(
    backgroundColor: AgrisellColors.forestGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.all(12),
  );

  static const composer = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(top: BorderSide(color: AgrisellColors.borderLine)),
  );

  static const reopenNote = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.statusOrangeText,
  );

  static const composerPadding = EdgeInsets.fromLTRB(12, 8, 12, 10);
  static const reopenPadding = EdgeInsets.only(bottom: 6, left: 4);
}
