import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/styles/farmer_reviews_screen_styles.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/utils/farmer_reviews_appeal_handler.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_error_card.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_header.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_search_bar.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_widgets.dart';

class FarmerReviewsScreen extends StatefulWidget {
  const FarmerReviewsScreen({this.farmerId, this.controller, super.key});

  final String? farmerId;
  final FarmerReviewsController? controller;

  @override
  State<FarmerReviewsScreen> createState() => _FarmerReviewsScreenState();
}

class _FarmerReviewsScreenState extends State<FarmerReviewsScreen> {
  late final FarmerReviewsController _controller;
  late final bool _ownsController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? FarmerReviewsController();
    unawaited(_controller.loadReviews(farmerId: widget.farmerId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerReviewsScreenStyles.screenBackground,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            FarmerReviewsHeader(
              onBack: () => Navigator.of(context).pop(),
              onRefresh: () =>
                  unawaited(_controller.loadReviews(farmerId: widget.farmerId)),
            ),
            FarmerReviewsSearchBar(
              controller: _searchController,
              onChanged: _controller.setSearchQuery,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => RefreshIndicator(
                  color: FarmerReviewsScreenStyles.indicatorColor,
                  onRefresh: () =>
                      _controller.loadReviews(farmerId: widget.farmerId),
                  child: ListView(
                    padding: FarmerReviewsScreenStyles.listPadding,
                    children: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_controller.isLoading && _controller.allReviews.isEmpty) {
      return const [
        SizedBox(height: 60),
        Center(
          child: CircularProgressIndicator(
            color: FarmerReviewsScreenStyles.indicatorColor,
          ),
        ),
      ];
    }

    if (_controller.errorMessage != null && _controller.allReviews.isEmpty) {
      return [
        const SizedBox(height: 30),
        FarmerReviewsErrorCard(
          errorMessage: _controller.errorMessage!,
          onRetry: () =>
              unawaited(_controller.loadReviews(farmerId: widget.farmerId)),
        ),
      ];
    }

    if (!_controller.data.hasData) {
      return const [
        SizedBox(height: 30),
        FarmerReviewsEmptyCard(
          title: 'No reviews yet',
          message:
              'When buyers receive their orders and leave feedback on your products, their ratings and reviews will appear here.',
        ),
      ];
    }

    final filtered = _controller.filteredReviews;

    return [
      FarmerRatingsOverviewCard(summary: _controller.summary),
      const SizedBox(height: 14),
      FarmerReviewsFilterBar(
        selectedFilter: _controller.filter,
        onFilterSelected: _controller.setFilter,
        moderatedCount: _controller.summary.moderatedCount,
      ),
      const SizedBox(height: 14),
      if (filtered.isEmpty)
        const FarmerReviewsEmptyCard(
          title: 'No matching reviews',
          message: 'Try selecting a different filter or clearing your search.',
        )
      else
        ...filtered.map(
          (r) => FarmerReviewCard(
            review: r,
            onReportReview: (review) => FarmerReviewsAppealHandler.handleReport(
              context: context,
              review: review,
              controller: _controller,
              farmerId: widget.farmerId,
            ),
            onAppealModeration: (review) =>
                FarmerReviewsAppealHandler.handleAppeal(
                  context: context,
                  review: review,
                  controller: _controller,
                  farmerId: widget.farmerId,
                ),
          ),
        ),
    ];
  }
}
