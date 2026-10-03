import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_palette_styles.dart';
import 'package:flutter/material.dart';

abstract final class FarmerProfileStyles {
  static BoxDecoration containerDecoration(Color color) => BoxDecoration(
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
  );

  static final containerDecoration2 = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.13),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
  );
}
