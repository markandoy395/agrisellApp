import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class GcashMultiFarmNoticeStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
