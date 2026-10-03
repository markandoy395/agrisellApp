export 'package:agresell_app/features/shared/widgets/ratings/rating_stars_styles.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars_styles.dart';
import 'package:flutter/material.dart';

enum RatingStarPrecision { whole, half }

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    required this.style,
    this.precision = RatingStarPrecision.half,
    this.semanticLabel,
    super.key,
  });

  final double rating;
  final RatingStarsStyle style;
  final RatingStarPrecision precision;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel ?? '${rating.toStringAsFixed(1)} out of 5 stars',
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 5; index++)
            Icon(
              _iconFor(index),
              color: _isEmpty(index) ? style.emptyColor : style.filledColor,
              size: style.size,
            ),
        ],
      ),
    ),
  );

  IconData _iconFor(int index) {
    final amount = rating - index;
    if (amount >= 1) return Icons.star_rounded;
    if (precision == RatingStarPrecision.half && amount >= 0.5) {
      return Icons.star_half_rounded;
    }
    return style.emptyIcon;
  }

  bool _isEmpty(int index) {
    final amount = rating - index;
    return amount < 1 &&
        (precision == RatingStarPrecision.whole || amount < 0.5);
  }
}
