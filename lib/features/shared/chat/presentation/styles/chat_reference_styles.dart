import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_detail_header.dart';
import '../widgets/chat_message_composer.dart';

abstract final class ChatReferenceStyles {
  static const background = Color(0xFFF7F7FD);
  static const teal = Color(0xFF26756D);
  static const title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: Color(0xFF172323),
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const subtitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: Color(0xFF85898E),
    fontSize: 12,
    height: 1.5,
  );
  static const headerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
  );
  static const composerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(top: BorderSide(color: AgrisellColors.borderLine)),
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  static const contextDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );
  static ChatAvatarStyle avatar(double diameter) => ChatAvatarStyle(
    diameter: diameter,
    backgroundColor: const Color(0xFFE4F0ED),
    foregroundColor: teal,
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  );
  static ChatDetailHeaderStyle header(double topInset) => ChatDetailHeaderStyle(
    padding: EdgeInsets.fromLTRB(8, topInset + 10, 12, 16),
    decoration: headerDecoration,
    avatarStyle: avatar(44),
    titleStyle: title,
    subtitleStyle: subtitle,
  );
  static final input = InputDecoration(
    hintStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      color: AgrisellColors.mutedText,
      fontSize: 13,
    ),
    filled: true,
    fillColor: AgrisellColors.pageBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AgrisellColors.borderLine),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AgrisellColors.borderLine),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
    ),
  );
  static final sendButton = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    disabledBackgroundColor: AgrisellColors.forestSoft,
    disabledForegroundColor: AgrisellColors.mutedText,
    minimumSize: const Size(48, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  static final actionButton = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF172323),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFEDEEF2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
  static ChatMessageComposerStyle composer(double bottom, String hint) =>
      ChatMessageComposerStyle(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom),
        decoration: composerDecoration,
        hintText: hint,
        inputDecoration: input,
        maxLines: 3,
        sendButtonSize: const Size(48, 48),
      );
}
