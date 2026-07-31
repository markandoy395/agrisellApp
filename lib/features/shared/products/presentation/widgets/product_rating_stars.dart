import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class ProductRatingStars extends StatelessWidget {
  const ProductRatingStars({
    this.size = 17,
    this.showHalfStar = true,
    super.key,
  });

  final double size;
  final bool showHalfStar;

  @override
  Widget build(BuildContext context) {
    final fullStars = showHalfStar ? 4 : 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < fullStars; index++)
          Icon(
            Icons.star_rounded,
            color: AgrisellColors.accentOrange,
            size: size,
          ),
        if (showHalfStar)
          Icon(
            Icons.star_half_rounded,
            color: AgrisellColors.accentOrange,
            size: size,
          ),
      ],
    );
  }
}
