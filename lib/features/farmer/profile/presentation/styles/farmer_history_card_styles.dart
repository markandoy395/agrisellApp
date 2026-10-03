import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';

abstract final class FarmerHistoryCardStyles {
  static final viewAllText = TextStyle(
    color: FarmerProfileStyle.green,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: FarmerProfileStyle.borderSubtle, width: 1),
  );

  static const labelText = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
