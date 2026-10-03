import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class LocationMapPreviewStyles {
  static final inkDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface.withValues(alpha: .94),
    borderRadius: BorderRadius.circular(8),
  );
}
