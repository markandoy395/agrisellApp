import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_ratings_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderRatingsScreen extends StatefulWidget {
  const RiderRatingsScreen({this.riderId = '', this.controller, super.key});

  final String riderId;
  final RiderAnalyticsController? controller;

  @override
  State<RiderRatingsScreen> createState() => _RiderRatingsScreenState();
}

class _RiderRatingsScreenState extends State<RiderRatingsScreen> {
  late final RiderAnalyticsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderAnalyticsController();
    unawaited(_controller.loadRatings(riderId: widget.riderId));
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Ratings & reviews',
          subtitle: 'Customer feedback and delivery performance',
          action: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: AgrisellColors.surface,
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(14),
              children: _content(),
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _content() {
    return switch (_controller.ratingsState) {
      RiderAnalyticsLoadState.idle || RiderAnalyticsLoadState.loading => const [
        RiderLoadingStateCard(
          title: 'Loading ratings',
          message: 'Retrieving customer reviews and delivery metrics.',
        ),
      ],
      RiderAnalyticsLoadState.error => [
        RiderErrorStateCard(
          title: 'Ratings unavailable',
          message: _controller.ratingsError ?? 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () =>
              unawaited(_controller.loadRatings(riderId: widget.riderId)),
        ),
      ],
      RiderAnalyticsLoadState.ready when !_controller.ratings.hasData => const [
        RiderEmptyStateCard(
          title: 'No ratings yet',
          message:
              'Buyer and farmer reviews plus helpful delivery performance metrics will appear here.',
          icon: Icons.star_outline_rounded,
        ),
      ],
      RiderAnalyticsLoadState.ready => [
        RiderRatingsOverview(summary: _controller.ratings.summary),
        if (_controller.ratings.reviews.isNotEmpty) ...[
          const SizedBox(height: 14),
          RiderReviewList(reviews: _controller.ratings.reviews),
        ],
      ],
    };
  }
}
