import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reviews/data/farmer_reviews_repository.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/review_report_appeal_sheet.dart';

void main() {
  group('Farmer Reviews Hub SQL Contract Tests', () {
    test('hub migration exists in both app and admin dashboard', () {
      final appFile = File(
        'supabase/migrations/20260919200000_add_farmer_reviews_hub_rpc.sql',
      );
      final adminFile = File(
        '../agrisellDashboard/agrisellAdmin/supabase/migrations/20260919200000_add_farmer_reviews_hub_rpc.sql',
      );

      expect(appFile.existsSync(), isTrue);
      expect(adminFile.existsSync(), isTrue);
      expect(appFile.readAsStringSync(), adminFile.readAsStringSync());
    });

    test('hub migration defines current_farmer_reviews RPC and security permissions', () {
      final sql = File(
        'supabase/migrations/20260919200000_add_farmer_reviews_hub_rpc.sql',
      ).readAsStringSync();

      expect(sql.contains('create or replace function public.current_farmer_reviews()'), isTrue);
      expect(sql.contains('security definer'), isTrue);
      expect(sql.contains('from public.reviews as review'), isTrue);
      expect(sql.contains('left join public.admin_review_moderation as moderation'), isTrue);
      expect(sql.contains('left join lateral ('), isTrue);
      expect(sql.contains('from public.admin_review_responses as response'), isTrue);
      expect(sql.contains('grant execute on function public.current_farmer_reviews() to authenticated;'), isTrue);
    });

    test('reports and appeals migration exists and matches in both app and admin dashboard', () {
      final appFile = File(
        'supabase/migrations/20260921130000_add_farmer_review_reports_and_appeals.sql',
      );
      final adminFile = File(
        '../agrisellDashboard/agrisellAdmin/supabase/migrations/20260921130000_add_farmer_review_reports_and_appeals.sql',
      );

      expect(appFile.existsSync(), isTrue);
      expect(adminFile.existsSync(), isTrue);
      expect(appFile.readAsStringSync(), adminFile.readAsStringSync());
    });

    test('reports and appeals migration defines farmer_review_appeals and submit RPC', () {
      final sql = File(
        'supabase/migrations/20260921130000_add_farmer_review_reports_and_appeals.sql',
      ).readAsStringSync();

      expect(sql.contains('create table if not exists public.farmer_review_appeals'), isTrue);
      expect(sql.contains('create or replace function public.submit_farmer_review_report_or_appeal'), isTrue);
      expect(sql.contains('security definer'), isTrue);
      expect(sql.contains('insert into public.farmer_review_appeals'), isTrue);
      expect(sql.contains('insert into public.admin_review_moderation'), isTrue);
      expect(sql.contains('insert into public.admin_review_moderation_events'), isTrue);
      expect(sql.contains('grant execute on function public.submit_farmer_review_report_or_appeal'), isTrue);
    });
  });

  group('Farmer Reviews Domain Models', () {
    test('FarmerReview serialization and getters work correctly', () {
      final now = DateTime.now();
      final review = FarmerReview(
        id: 'rev-001',
        orderId: 42,
        clientOrderId: 'AG-42',
        commodityId: 10,
        commodityName: 'Baguio Strawberries',
        rating: 4.5,
        comment: 'Fresh and delicious.',
        createdAt: now,
        buyerName: 'Juan Dela Cruz',
        visibilityStatus: 'published',
        reportStatus: 'resolved',
        abuseFlags: const ['other'],
        adminModerationNote: 'Packaging issue noted and resolved.',
        adminResponse: 'We have updated our packing standard.',
        adminResponseMode: 'public',
        adminRespondedAt: now,
      );

      expect(review.hasAdminNote, isTrue);
      expect(review.isHidden, isFalse);
      expect(review.isFlagged, isTrue);
      expect(review.hasAdminResponse, isTrue);
      expect(review.isReportOpen, isFalse);
      expect(review.canReport, isTrue);
      expect(review.canAppeal, isTrue);

      final json = review.toJson();
      final fromJson = FarmerReview.fromJson(json);

      expect(fromJson.id, review.id);
      expect(fromJson.clientOrderId, 'AG-42');
      expect(fromJson.commodityName, 'Baguio Strawberries');
      expect(fromJson.rating, 4.5);
      expect(fromJson.adminModerationNote, 'Packaging issue noted and resolved.');
      expect(fromJson.adminResponse, 'We have updated our packing standard.');
    });

    test('FarmerReview report & appeal capability states', () {
      final now = DateTime.now();

      // Standard clean review: can report, cannot appeal
      final cleanReview = FarmerReview(
        id: 'rev-clean',
        orderId: 1,
        clientOrderId: 'AG-1',
        commodityId: 1,
        commodityName: 'Tomatoes',
        rating: 5.0,
        createdAt: now,
        buyerName: 'Anna',
      );
      expect(cleanReview.isReportOpen, isFalse);
      expect(cleanReview.canReport, isTrue);
      expect(cleanReview.canAppeal, isFalse);

      // Review currently open for report/appeal: cannot report again or appeal while open
      final openReview = cleanReview.copyWith(reportStatus: 'open');
      expect(openReview.isReportOpen, isTrue);
      expect(openReview.canReport, isFalse);
      expect(openReview.canAppeal, isFalse);

      // Hidden review: can appeal
      final hiddenReview = cleanReview.copyWith(visibilityStatus: 'hidden');
      expect(hiddenReview.canAppeal, isTrue);
      expect(hiddenReview.canReport, isTrue);

      // Presets exist
      expect(FarmerReview.reportReasons.length, greaterThanOrEqualTo(5));
      expect(FarmerReview.appealGrounds.length, greaterThanOrEqualTo(5));
    });

    test('FarmerRatingsSummary calculates percentages correctly', () {
      const summary = FarmerRatingsSummary(
        averageRating: 4.2,
        totalReviews: 10,
        fiveStarCount: 5,
        fourStarCount: 3,
        threeStarCount: 1,
        twoStarCount: 1,
        oneStarCount: 0,
        moderatedCount: 2,
      );

      expect(summary.fiveStarPercent, 50.0);
      expect(summary.fourStarPercent, 30.0);
      expect(summary.threeStarPercent, 10.0);
      expect(summary.twoStarPercent, 10.0);
      expect(summary.oneStarPercent, 0.0);
      expect(summary.isEmpty, isFalse);
    });
  });

  group('FarmerReviewsController Tests', () {
    late InMemoryFarmerReviewsRepository repo;
    late FarmerReviewsController controller;

    setUp(() {
      repo = InMemoryFarmerReviewsRepository();
      controller = FarmerReviewsController(repository: repo);
    });

    test('loads reviews and calculates filtered list', () async {
      await controller.loadReviews();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.allReviews.length, 5);
      expect(controller.summary.totalReviews, 5);
      expect(controller.summary.averageRating, 4.4);

      // Star filter
      controller.setFilter(FarmerReviewsFilter.fiveStar);
      expect(controller.filteredReviews.length, 3);

      controller.setFilter(FarmerReviewsFilter.fourStar);
      expect(controller.filteredReviews.length, 1);

      controller.setFilter(FarmerReviewsFilter.threeStar);
      expect(controller.filteredReviews.length, 1);

      // Admin notes filter
      controller.setFilter(FarmerReviewsFilter.withNotes);
      expect(controller.filteredReviews.length, 1);
      expect(controller.filteredReviews.first.adminModerationNote, contains('Reviewed by Support'));

      // Search query
      controller.setFilter(FarmerReviewsFilter.all);
      controller.setSearchQuery('lettuce');
      expect(controller.filteredReviews.length, 1);
      expect(controller.filteredReviews.first.commodityName, contains('Lettuce'));

      controller.setSearchQuery('maria');
      expect(controller.filteredReviews.length, 1);
      expect(controller.filteredReviews.first.buyerName, contains('Maria'));
    });

    test('submitReportOrAppeal mutates review state to open report', () async {
      await controller.loadReviews();

      final firstReview = controller.allReviews.first;
      expect(firstReview.isReportOpen, isFalse);

      final success = await controller.submitReportOrAppeal(
        reviewId: firstReview.id,
        actionType: 'report',
        reason: 'Malicious or Competitor Attack',
        details: 'Reviewer never received this product variant',
      );

      expect(success, isTrue);
      expect(controller.errorMessage, isNull);

      final updatedReview = controller.allReviews.firstWhere((r) => r.id == firstReview.id);
      expect(updatedReview.isReportOpen, isTrue);
      expect(updatedReview.adminModerationNote, contains('Farmer Report: [Malicious or Competitor Attack]'));
    });
  });

  group('FarmerReviewsScreen Widget Tests', () {
    testWidgets('renders review cards with report and appeal moderation action buttons', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = InMemoryFarmerReviewsRepository();
      final controller = FarmerReviewsController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: FarmerReviewsScreen(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Reviews & Ratings'), findsOneWidget);

      // Verify "Report Review" buttons are rendered
      expect(find.text('Report Review'), findsWidgets);

      // Verify "Appeal Moderation" button is rendered on the 3-star review with notes
      expect(find.text('Appeal Moderation'), findsOneWidget);

      // Tap "Report Review" on the first review
      final reportButtons = find.text('Report Review');
      await tester.tap(reportButtons.first);
      await tester.pumpAndSettle();

      // Verify modal bottom sheet appeared
      expect(find.byType(ReviewReportAppealSheet), findsOneWidget);
      expect(find.text('Select Reason for Reporting'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);

      // Select another reason
      await tester.tap(find.text('Malicious or Competitor Attack'));
      await tester.pumpAndSettle();

      // Tap Submit
      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();

      // Modal closed and status pill appeared
      expect(find.byType(ReviewReportAppealSheet), findsNothing);
      expect(find.text('Report / Appeal Under Admin Review'), findsOneWidget);
    });
  });
}
