import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _starStyle = RatingStarsStyle(
  size: 18,
  filledColor: AgrisellColors.accentOrange,
  emptyColor: AgrisellColors.brandBlack,
);

void main() {
  group('Rating stars', () {
    for (final rating in [0.0, 5.0]) {
      testWidgets('$rating rating renders exactly five stars', (tester) async {
        await _pumpRating(tester, rating);

        expect(find.byType(Icon), findsNWidgets(5));
        expect(find.byIcon(Icons.star_rounded), findsNWidgets(rating.toInt()));
        expect(
          find.byIcon(Icons.star_border_rounded),
          findsNWidgets(5 - rating.toInt()),
        );
        expect(find.byIcon(Icons.star_half_rounded), findsNothing);
      });
    }

    testWidgets('half stars begin at the half-point boundary', (tester) async {
      await _pumpRating(tester, 3.49);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half_rounded), findsNothing);
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(2));

      await _pumpRating(tester, 3.5);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });

    testWidgets('rebuild updates the stars and accessible rating', (
      tester,
    ) async {
      await _pumpRating(tester, 1);
      expect(find.bySemanticsLabel('1.0 out of 5 stars'), findsOneWidget);

      await _pumpRating(tester, 4);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.bySemanticsLabel('4.0 out of 5 stars'), findsOneWidget);
      expect(find.bySemanticsLabel('1.0 out of 5 stars'), findsNothing);
    });

    testWidgets('custom accessible label replaces the default label', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStars(
              rating: 4.5,
              style: _starStyle,
              semanticLabel: 'Seller rating: 4.5 from 12 reviews',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Seller rating: 4.5 from 12 reviews'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('4.5 out of 5 stars'), findsNothing);
    });
  });
}

Future<void> _pumpRating(WidgetTester tester, double rating) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RatingStars(rating: rating, style: _starStyle),
      ),
    ),
  );
}
