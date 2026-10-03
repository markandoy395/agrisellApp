import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

abstract final class ProfileEditCardStyles {
  static const personalInformationText = TextStyle(
    fontFamily: 'Poppins',
    color: BuyerProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const updateYourAccountDetailsText = TextStyle(
    fontFamily: 'Poppins',
    color: BuyerProfileStyle.muted,
    fontSize: 15,
  );
}
