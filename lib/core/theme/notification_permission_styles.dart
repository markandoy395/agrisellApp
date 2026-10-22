import 'package:flutter/material.dart';
import 'agrisell_colors.dart';

abstract final class NotificationPermissionStyles {
  static const padding = EdgeInsets.all(16);
  static const margin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static const message = TextStyle(
    fontSize: 14,
    color: AgrisellColors.headingGreen,
  );
}
