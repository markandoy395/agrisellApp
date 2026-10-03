import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderDetailsScreenStyles {
  static const printDownloadDeliveryWaybillText = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 13,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    backgroundColor: AgrisellColors.surface,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
