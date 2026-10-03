import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BuyerChatScreenStyles {
  static const chatDetailHeaderStyleDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const chatMessageComposerStyleDecoration = BoxDecoration(
    color: AgrisellColors.surface,
  );

  static final inputDecoration = InputDecoration(
    hintStyle: const TextStyle(fontSize: 13),
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
  );
}
