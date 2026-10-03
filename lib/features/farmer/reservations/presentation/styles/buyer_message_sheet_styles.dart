import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BuyerMessageSheetStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(999),
  );

  static InputDecoration inputDecoration(
    BuildContext context,
    OutlineInputBorder value2,
    OutlineInputBorder value3,
  ) => InputDecoration(
    hintText: 'Write a message',
    contentPadding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
    suffixIcon: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.send_rounded),
      color: AgrisellColors.authGreen,
      tooltip: 'Send message',
    ),
    border: value2,
    enabledBorder: value2,
    focusedBorder: value3,
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w500,
  );
}
