import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class FarmerProfileStyle {
  // Core brand palette
  static const green = Color(0xFF08683F);
  static const deepGreen = Color(0xFF054D2D);
  static const richGreen = Color(0xFF0A7A49);
  static const mint = Color(0xFFE5F7EF);
  static const mintDeep = Color(0xFFCDF0DC);
  static const ink = Color(0xFF071E27);
  static const muted = Color(0xFF687781);
  static const background = Color(0xFFF0F5F2);
  static const surface = Color(0xFFFFFFFF);
  static const borderSubtle = Color(0xFFE3EDE8);

  // Gradient presets
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF062E1D), Color(0xFF0B5435), Color(0xFF0E6B43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  // Typography tokens aligned with centralized AppTypography scale
  static const heading = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const sectionLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: Color(0xFF3A6652),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const tileTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const tileSubtitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: muted,
    fontSize: 13,
    height: 1.35,
  );
}

/// Modern elevated card with subtle shadow + border.
class FarmerProfileCard extends StatelessWidget {
  const FarmerProfileCard({
    required this.child,
    this.color = FarmerProfileStyle.surface,
    super.key,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: FarmerProfileStyle.borderSubtle, width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF08683F).withValues(alpha: 0.07),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

/// Glassy overlay widget for use inside gradient containers.
class GlassChip extends StatelessWidget {
  const GlassChip({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    ),
    child: child,
  );
}
