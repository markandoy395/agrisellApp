import 'package:flutter/material.dart';

class RatingStarsStyle {
  const RatingStarsStyle({
    required this.size,
    required this.filledColor,
    required this.emptyColor,
    this.emptyIcon = Icons.star_border_rounded,
  });

  final double size;
  final Color filledColor;
  final Color emptyColor;
  final IconData emptyIcon;
}
