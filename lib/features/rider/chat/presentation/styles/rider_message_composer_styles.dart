import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'rider_messaging_design_styles.dart';

abstract final class RiderMessageComposerStyles {
  static final inputDecoration = InputDecoration(
    hintText: 'Write a delivery message',
    hintStyle: RiderMessagingDesignStyles.muted,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
  static final container = BoxDecoration(
    color: AgrisellColors.forestSoft.withValues(alpha: .4),
    border: Border.all(color: AgrisellColors.borderLine),
    borderRadius: const BorderRadius.all(Radius.circular(22)),
  );
  static final iconButtonStyle = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    disabledBackgroundColor: AgrisellColors.deliveryGray,
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(14),
  );
}
