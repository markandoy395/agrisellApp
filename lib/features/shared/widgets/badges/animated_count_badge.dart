import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
