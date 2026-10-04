import 'package:flutter/material.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_detail_header.dart';
import '../widgets/chat_message_composer.dart';

abstract final class ChatReferenceStyles {
  static const background = Color(0xFFF7F7FD);
  static const teal = Color(0xFF26756D);
  static const title = TextStyle(
    color: Color(0xFF172323),
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const subtitle = TextStyle(
    color: Color(0xFF85898E),
    fontSize: 12,
    height: 1.5,
  );
  static const headerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
  );
  static const composerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );
  static const contextDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );
  static ChatAvatarStyle avatar(double diameter) => ChatAvatarStyle(
    diameter: diameter,
    backgroundColor: const Color(0xFFE4F0ED),
    foregroundColor: teal,
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  );
  static ChatDetailHeaderStyle header(double topInset) => ChatDetailHeaderStyle(
    padding: EdgeInsets.fromLTRB(8, topInset + 10, 12, 16),
    decoration: headerDecoration,
    avatarStyle: avatar(44),
    titleStyle: title,
    subtitleStyle: subtitle,
  );
  static final input = InputDecoration(
    hintStyle: const TextStyle(color: Color(0xFF85898E), fontSize: 14),
    filled: true,
    fillColor: background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Color(0xFFE9EBEF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Color(0xFFE9EBEF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: teal),
    ),
  );
  static final sendButton = IconButton.styleFrom(
    backgroundColor: teal,
    foregroundColor: Colors.white,
    minimumSize: const Size(54, 54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
  );
  static final actionButton = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF172323),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFEDEEF2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
  static ChatMessageComposerStyle composer(double bottom, String hint) =>
      ChatMessageComposerStyle(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom),
        decoration: composerDecoration,
        hintText: hint,
        inputDecoration: input,
        maxLines: 3,
        sendButtonSize: const Size(54, 54),
      );
}
