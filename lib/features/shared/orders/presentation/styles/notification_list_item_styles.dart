import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_style.dart';

abstract final class NotificationListItemStyles {
  static const cardPadding = EdgeInsets.fromLTRB(12, 12, 6, 12);
  static final cardRadius = BorderRadius.circular(16);

  static const unreadDotSize = 8.0;

  static const dateStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const descriptionStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static TextStyle titleStyle({required bool isRead}) => TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.25,
    fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
  );

  static BoxDecoration unreadDotDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
  );

  static BoxDecoration cardDecoration({
    required bool isRead,
    required NotificationStyle style,
  }) => BoxDecoration(
    color: isRead ? AgrisellColors.surface : style.background,
    borderRadius: cardRadius,
    border: Border.all(
      color: isRead ? AgrisellColors.borderLine : style.color,
      width: isRead ? 1 : 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.055),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
