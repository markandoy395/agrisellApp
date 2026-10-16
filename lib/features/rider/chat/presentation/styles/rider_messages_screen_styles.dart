import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'rider_messaging_design_styles.dart';

abstract final class RiderMessagesScreenStyles {
  static final inputDecoration = InputDecoration(
    hintText: 'Search delivery messages',
    hintStyle: RiderMessagingDesignStyles.muted,
    prefixIcon: const Icon(
      Icons.search_rounded,
      color: AgrisellColors.mutedText,
    ),
    filled: true,
    fillColor: AgrisellColors.forestSoft.withValues(alpha: .4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: const OutlineInputBorder(
      borderRadius: RiderMessagingDesignStyles.radius,
      borderSide: BorderSide(color: AgrisellColors.borderLine),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: RiderMessagingDesignStyles.radius,
      borderSide: BorderSide(color: AgrisellColors.borderLine),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: RiderMessagingDesignStyles.radius,
      borderSide: BorderSide(color: AgrisellColors.authGreen),
    ),
  );
}
