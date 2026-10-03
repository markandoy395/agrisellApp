import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ImageLoadingSkeletonStyles {
  static BoxDecoration decoratedBoxDecoration(double offset) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(offset, 0),
      end: Alignment(offset + 1, 0),
      colors: const [
        AgrisellColors.searchBackground,
        AgrisellColors.borderLine,
        AgrisellColors.searchBackground,
      ],
    ),
  );
}
