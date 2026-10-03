import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryRequestCardContentStyles {
  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    height: 1.15,
    fontWeight: FontWeight.w800,
  );

  static final buttonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    minimumSize: const Size.fromHeight(38),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static final buttonStyle2 = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    minimumSize: const Size.fromHeight(38),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
