import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerReserveSkeletonStyles {
  static const card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const block = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );
}
