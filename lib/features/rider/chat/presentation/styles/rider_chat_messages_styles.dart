import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'rider_messaging_design_styles.dart';

abstract final class RiderChatMessagesStyles {
  static BoxDecoration decoratedBoxDecoration(bool sentByRider) =>
      BoxDecoration(
        color: sentByRider ? AgrisellColors.forestSoft : AgrisellColors.surface,
        borderRadius: RiderMessagingDesignStyles.radius,
        border: Border.all(
          color: sentByRider
              ? AgrisellColors.deliveryGreen.withValues(alpha: .4)
              : AgrisellColors.borderLine,
        ),
      );
  static TextStyle textStyle(bool sentByRider) =>
      RiderMessagingDesignStyles.body;
  static final textStyle2 = RiderMessagingDesignStyles.caption;
  static final day = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(24),
  );
}
