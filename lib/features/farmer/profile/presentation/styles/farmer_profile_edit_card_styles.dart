import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';

abstract final class FarmerProfileEditCardStyles {
  static const personalInformationText = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const updateYourAccountDetailsText = TextStyle(
    color: FarmerProfileStyle.muted,
    fontSize: 15,
  );
}
