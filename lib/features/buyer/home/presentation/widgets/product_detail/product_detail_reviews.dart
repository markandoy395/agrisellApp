import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_reviews_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_review_tile.dart';
import 'package:agresell_app/features/shared/products/data/product_reviews.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_review.dart';

class ProductDetailReviews extends StatefulWidget {
  const ProductDetailReviews({
    required this.product,
    this.repository = const ProductReviewRepository(),
    super.key,
  });

  final HomeProduct product;
  final ProductReviewRepository repository;

  @override
  State<ProductDetailReviews> createState() => _ProductDetailReviewsState();
}

class _ProductDetailReviewsState extends State<ProductDetailReviews> {
  late Future<ProductReviewSummary> _reviews;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProductDetailReviews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) _load();
  }

  void _load() => _reviews = widget.repository.load(widget.product.id);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ProductDetailReviewsStyles.decoratedBoxDecoration,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: FutureBuilder<ProductReviewSummary>(
        future: _reviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _ReviewLoadingState();
          }
          if (snapshot.hasError) return _ReviewErrorState(onRetry: _retry);
          final data = snapshot.data ?? const ProductReviewSummary.empty();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewSummaryHeader(data: data),
              if (data.reviews.isEmpty)
                const _NoReviewsState()
              else
                for (final review in data.reviews) ...[
                  const Divider(height: 20, color: AgrisellColors.borderLine),
                  ProductDetailReviewTile(review: review),
                ],
            ],
          );
        },
      ),
    ),
  );

  void _retry() => setState(_load);
}

class _ReviewSummaryHeader extends StatelessWidget {
  const _ReviewSummaryHeader({required this.data});

  final ProductReviewSummary data;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buyer feedback',
              style: SharedPresentationStyles.headingTitleBlack,
            ),
            SizedBox(height: 2),
            Text(
              'Ratings from completed orders',
              style: SharedPresentationStyles.mutedCaption,
            ),
          ],
        ),
      ),
      if (data.reviewCount > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: ProductDetailReviewsStyles.containerDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AgrisellColors.accentOrange,
                size: 17,
              ),
              const SizedBox(width: 3),
              Text(
                '${data.averageRating.toStringAsFixed(1)} (${data.reviewCount})',
                style: ProductDetailReviewsStyles.textStyle,
              ),
            ],
          ),
        ),
    ],
  );
}

class _NoReviewsState extends StatelessWidget {
  const _NoReviewsState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 14),
    child: Row(
      children: [
        Icon(
          Icons.chat_bubble_outline,
          color: AgrisellColors.mutedText,
          size: 18,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'No verified buyer reviews yet.',
            style: SharedPresentationStyles.mutedCaption,
          ),
        ),
      ],
    ),
  );
}

class _ReviewLoadingState extends StatelessWidget {
  const _ReviewLoadingState();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 70,
    child: Center(
      child: CircularProgressIndicator(
        color: AgrisellColors.authGreen,
        strokeWidth: 2.5,
      ),
    ),
  );
}

class _ReviewErrorState extends StatelessWidget {
  const _ReviewErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'Buyer feedback could not be loaded.',
          style: SharedPresentationStyles.mutedCaption,
        ),
      ),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}
