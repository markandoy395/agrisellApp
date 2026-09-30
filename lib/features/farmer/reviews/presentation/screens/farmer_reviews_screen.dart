import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/farmer_reviews_widgets.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/review_report_appeal_sheet.dart';

class FarmerReviewsScreen extends StatefulWidget {
  const FarmerReviewsScreen({
    this.farmerId,
    this.controller,
    super.key,
  });

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
      backgroundColor: AgrisellColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => RefreshIndicator(
                  color: AgrisellColors.authGreen,
                  onRefresh: () =>
                      _controller.loadReviews(farmerId: widget.farmerId),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AgrisellColors.authGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AgrisellColors.surface,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviews & Ratings',
                  style: TextStyle(
                    color: AgrisellColors.surface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Buyer feedback & admin moderation',
                  style: TextStyle(
                    color: Color(0xFFD3EADE),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                unawaited(_controller.loadReviews(farmerId: widget.farmerId)),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AgrisellColors.surface,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by product, buyer, or comment...',
          hintStyle: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AgrisellColors.authGreen,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AgrisellColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E9EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E9EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AgrisellColors.authGreen,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_controller.isLoading && _controller.allReviews.isEmpty) {
      return const [
        SizedBox(height: 60),
        Center(
          child: CircularProgressIndicator(color: AgrisellColors.authGreen),
        ),
      ];
    }

    if (_controller.errorMessage != null && _controller.allReviews.isEmpty) {
      return [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AgrisellColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB82828),
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => unawaited(
                  _controller.loadReviews(farmerId: widget.farmerId),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  foregroundColor: AgrisellColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
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
            onReportReview: _handleReportReview,
            onAppealModeration: _handleAppealModeration,
          ),
        ),
    ];
  }

  Future<void> _handleReportReview(FarmerReview review) async {
    final submitted = await ReviewReportAppealSheet.show(
      context,
      review: review,
      actionType: 'report',
      onSubmit: ({required reason, details}) async {
        return _controller.submitReportOrAppeal(
          reviewId: review.id,
          actionType: 'report',
          reason: reason,
          details: details,
          farmerId: widget.farmerId,
        );
      },
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report for "${review.commodityName}" review submitted to moderators.',
          ),
          backgroundColor: AgrisellColors.headingGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleAppealModeration(FarmerReview review) async {
    final submitted = await ReviewReportAppealSheet.show(
      context,
      review: review,
      actionType: 'appeal',
      onSubmit: ({required reason, details}) async {
        return _controller.submitReportOrAppeal(
          reviewId: review.id,
          actionType: 'appeal',
          reason: reason,
          details: details,
          farmerId: widget.farmerId,
        );
      },
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appeal for "${review.commodityName}" review submitted to administrators.',
          ),
          backgroundColor: AgrisellColors.authGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
