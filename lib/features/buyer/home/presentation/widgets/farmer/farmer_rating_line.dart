import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerRatingLine extends StatelessWidget {
  const FarmerRatingLine({required this.rating, this.starSize, super.key});

  final double rating;
  final double? starSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedStarSize =
            starSize ?? (constraints.maxWidth < 118 ? 18.0 : 22.0);

        return Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [_RatingStars(rating: rating, size: resolvedStarSize)],
        );
      },
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating, required this.size});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(_iconFor(index), color: _colorFor(index), size: size),
      ],
    );
  }

  IconData _iconFor(int index) {
    final fullValue = index + 1;
    if (rating >= fullValue) {
      return Icons.star_rounded;
    }

    if (rating >= index + 0.5) {
      return Icons.star_half_rounded;
    }

    return Icons.star_rounded;
  }

  Color _colorFor(int index) {
    if (rating >= index + 0.5) {
      return AgrisellColors.accentOrange;
    }

    return AgrisellColors.brandBlack;
  }
}
