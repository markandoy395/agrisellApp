import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerFollowButtonStyles {
  static ButtonStyle buttonStyle(bool onDarkBackground, bool compact) =>
      FilledButton.styleFrom(
        backgroundColor: onDarkBackground
            ? AgrisellColors.surface
            : AgrisellColors.authGreen,
        foregroundColor: onDarkBackground
            ? AgrisellColors.authGreen
            : AgrisellColors.surface,
        disabledBackgroundColor: onDarkBackground
            ? AgrisellColors.surface.withValues(alpha: 0.72)
            : AgrisellColors.authGreen.withValues(alpha: 0.72),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  static ButtonStyle buttonStyle2(bool onDarkBackground, bool compact) =>
      OutlinedButton.styleFrom(
        foregroundColor: onDarkBackground
            ? AgrisellColors.surface
            : AgrisellColors.authGreen,
        side: BorderSide(
          color: onDarkBackground
              ? AgrisellColors.surface
              : AgrisellColors.authGreen,
          width: 1.2,
        ),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}
