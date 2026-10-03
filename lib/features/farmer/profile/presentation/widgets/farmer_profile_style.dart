import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_styles.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_palette_styles.dart';
export 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_palette_styles.dart';
import 'package:flutter/material.dart';

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
    decoration: FarmerProfileStyles.containerDecoration(color),
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
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: FarmerProfileStyles.containerDecoration2,
    child: child,
  );
}
