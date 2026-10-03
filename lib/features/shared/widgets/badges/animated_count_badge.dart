import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class AnimatedCountBadge extends StatelessWidget {
  const AnimatedCountBadge({
    required this.count,
    this.backgroundColor = AgrisellColors.authGreen,
    this.foregroundColor = AgrisellColors.surface,
    this.borderColor = AgrisellColors.surface,
    super.key,
  });

  final int count;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  String get label => count > 99 ? '99+' : count.toString();

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 220),
    switchInCurve: Curves.easeOutBack,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: FadeTransition(opacity: animation, child: child),
    ),
    child: Container(
      key: ValueKey(label),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: AnimatedCountBadgeStyles.containerDecoration(
        backgroundColor,
        borderColor,
      ),
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: AnimatedCountBadgeStyles.labelText(foregroundColor),
      ),
    ),
  );
}
