import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/utils/review_date_formatter.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_widgets.dart';

void main() {
  final review = FarmerReview(
    id: 'review-1',
    orderId: 1,
    clientOrderId: 'AG-1',
    commodityId: 1,
    commodityName: 'Tomatoes',
    rating: 4.5,
    comment: '  Fresh tomatoes  ',
    createdAt: DateTime(2026, 9, 18),
    buyerName: '',
    visibilityStatus: 'hidden',
    adminModerationNote: 'Moderation explanation',
    adminResponse: 'Support explanation',
  );

  Future<void> showWidget(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'hidden review preserves metadata, notices, and action callbacks',
    (tester) async {
      FarmerReview? reported;
      FarmerReview? appealed;
      await showWidget(
        tester,
        FarmerReviewCard(
          review: review,
          onReportReview: (value) => reported = value,
          onAppealModeration: (value) => appealed = value,
        ),
      );

      expect(find.text('B'), findsOneWidget);
      expect(find.text('Fresh tomatoes'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('• AG-1'), findsOneWidget);
      expect(
        find.text('Admin Moderation: Hidden from Marketplace'),
        findsOneWidget,
      );
      expect(find.text('Moderation explanation'), findsOneWidget);
      expect(find.text('Agrisell Support Response'), findsOneWidget);
      expect(find.text('Support explanation'), findsOneWidget);

      await tester.tap(find.text('Appeal Moderation'));
      await tester.tap(find.text('Report Review'));
      expect(appealed, same(review));
      expect(reported, same(review));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'open report replaces actions and omits blank comments and notes',
    (tester) async {
      await showWidget(
        tester,
        FarmerReviewCard(
          review: review.copyWith(
            reportStatus: 'open',
            visibilityStatus: 'published',
            comment: '   ',
            adminModerationNote: '   ',
            adminResponse: '   ',
          ),
        ),
      );

      expect(find.text('Report / Appeal Under Admin Review'), findsOneWidget);
      expect(find.text('Report Review'), findsNothing);
      expect(find.text('Appeal Moderation'), findsNothing);
      expect(find.text('Admin Moderation Note'), findsOneWidget);
      expect(find.text('Agrisell Support Response'), findsNothing);
      expect(find.text('   '), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'overview keeps distribution order and singular moderation text',
    (tester) async {
      await showWidget(
        tester,
        const FarmerRatingsOverviewCard(
          summary: FarmerRatingsSummary(
            averageRating: 5,
            totalReviews: 1,
            fiveStarCount: 1,
            moderatedCount: 1,
          ),
        ),
      );

      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('1 review'), findsOneWidget);
      expect(find.text('1 review has admin moderation notes'), findsOneWidget);
      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bars.map((bar) => bar.value), [1.0, 0.0, 0.0, 0.0, 0.0]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('filter chips preserve selection and counted notes callback', (
    tester,
  ) async {
    FarmerReviewsFilter? selected;
    await showWidget(
      tester,
      FarmerReviewsFilterBar(
        selectedFilter: FarmerReviewsFilter.fiveStar,
        moderatedCount: 2,
        onFilterSelected: (value) => selected = value,
      ),
    );

    final selectedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, FarmerReviewsFilter.fiveStar.label),
    );
    expect(selectedChip.selected, isTrue);
    expect(find.byType(ChoiceChip), findsNWidgets(7));
    await tester.tap(find.text('With Notes (2)'));
    expect(selected, FarmerReviewsFilter.withNotes);
  });

  test(
    'relative review dates preserve minute, hour, day, and week boundaries',
    () {
      final now = DateTime(2026, 10, 1, 12);
      final cases = <Duration, String>{
        const Duration(minutes: 1): 'Just now',
        const Duration(minutes: 2): '2 mins ago',
        const Duration(hours: 1): '1h ago',
        const Duration(days: 1): '1d ago',
        const Duration(days: 6): '6d ago',
        const Duration(days: 7): '9/24/2026',
      };
      for (final entry in cases.entries) {
        expect(
          formatFarmerReviewDate(now.subtract(entry.key), now: now),
          entry.value,
        );
      }
    },
  );
}
