import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';
import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge.dart';
import 'package:agresell_app/features/shared/widgets/buttons/circular_header_icon_button.dart';
import 'package:agresell_app/features/shared/widgets/metrics/summary_metric.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

void main() {
  testWidgets('animated count badge preserves its cap and compact geometry', (
    tester,
  ) async {
    await _pump(tester, const AnimatedCountBadge(count: 142));

    expect(find.text('99+'), findsOneWidget);
    final badge = tester.widget<Container>(find.byType(Container));
    expect(
      badge.constraints,
      const BoxConstraints(minWidth: 18, minHeight: 18),
    );
    expect(badge.padding, const EdgeInsets.symmetric(horizontal: 4));
  });

  testWidgets('rating stars support half and whole-star presentation', (
    tester,
  ) async {
    const style = RatingStarsStyle(
      size: 18,
      filledColor: AgrisellColors.accentOrange,
      emptyColor: AgrisellColors.brandBlack,
    );

    await _pump(tester, const RatingStars(rating: 2.5, style: style));

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(2));
    expect(_semanticsLabel('2.5 out of 5 stars'), findsOneWidget);

    await _pump(
      tester,
      const RatingStars(
        rating: 2.5,
        precision: RatingStarPrecision.whole,
        style: style,
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.star_half_rounded), findsNothing);
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(3));
  });

  testWidgets('product thumbnail preserves loader inputs and clipping', (
    tester,
  ) async {
    await _pump(
      tester,
      const ProductThumbnail(
        asset: 'assets/images/vege.jpeg',
        width: 78,
        height: 82,
        borderRadius: 12,
        semanticLabel: 'Vegetable product photo',
        gaplessPlayback: true,
      ),
    );

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(12));
    final image = tester.widget<ResponsiveAssetImage>(
      find.byType(ResponsiveAssetImage),
    );
    expect(image.asset, 'assets/images/vege.jpeg');
    expect(image.width, 78);
    expect(image.height, 82);
    expect(image.fit, BoxFit.cover);
    expect(image.semanticLabel, 'Vegetable product photo');
    expect(image.gaplessPlayback, isTrue);
  });

  testWidgets('circular header button preserves style, semantics, and tap', (
    tester,
  ) async {
    var tapped = false;
    await _pump(
      tester,
      CircularHeaderIconButton(
        semanticLabel: 'Go back',
        icon: Icons.arrow_back_rounded,
        onTap: () => tapped = true,
        style: const CircularHeaderIconButtonStyle.inkWell(
          dimension: 38,
          backgroundColor: Colors.black54,
          iconColor: Colors.white,
          iconSize: 22,
        ),
      ),
    );

    expect(_semanticsLabel('Go back'), findsOneWidget);
    final buttonBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(CircularHeaderIconButton),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 38,
        ),
      ),
    );
    expect(buttonBox.width, 38);
    expect(buttonBox.height, 38);
    final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
    expect(icon.size, 22);
    expect(icon.color, Colors.white);

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets('summary metric preserves width and text hierarchy', (
    tester,
  ) async {
    await _pump(
      tester,
      const SummaryMetric(label: 'Completed', value: '12', width: 92),
    );

    expect(tester.getSize(find.byType(SizedBox)).width, 92);
    final value = tester.widget<Text>(find.text('12'));
    final label = tester.widget<Text>(find.text('Completed'));
    expect(value.style?.fontWeight, FontWeight.w800);
    expect(value.style?.color, AgrisellColors.headingGreen);
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, AgrisellColors.mutedText);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

Finder _semanticsLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);
