import 'package:flutter/material.dart';

abstract final class FarmerSignupPersonalStepStyles {
  static final containerDecoration = BoxDecoration(
    color: Colors.green.shade50,
    shape: BoxShape.circle,
  );

  static const personalInformationText = TextStyle(
    color: Color(0xFF075239),
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const tellUsMoreAboutYourselfText = TextStyle(
    fontSize: 12,
    color: Colors.blueGrey,
  );
}
