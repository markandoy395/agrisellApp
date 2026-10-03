import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_feedback_card_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerFeedbackCard extends StatelessWidget {
  const FarmerFeedbackCard({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final reviews = <({String productName, OrderFeedback feedback})>[
      for (final item in order.items)
        if (item.feedback case final feedback?)
          (productName: item.productName, feedback: feedback),
    ];
    final orderFeedback = order.feedback;
    if (reviews.isEmpty && orderFeedback != null) {
      reviews.add((productName: order.title, feedback: orderFeedback));
    }

    return DecoratedBox(
      decoration: FarmerFeedbackCardStyles.decoratedBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SharedPresentationStyles.mutedCaptionBold,
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < reviews.length; index++) ...[
              if (index > 0)
                const Divider(height: 18, color: AgrisellColors.borderLine),
              _FeedbackEntry(
                productName: reviews[index].productName,
                feedback: reviews[index].feedback,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedbackEntry extends StatelessWidget {
  const _FeedbackEntry({required this.productName, required this.feedback});

  final String productName;
  final OrderFeedback feedback;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        productName,
        style: SharedPresentationStyles.headingSubtitleExtraBold,
      ),
      const SizedBox(height: 5),
      Semantics(
        label: '${feedback.rating} out of 5 stars',
        child: Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < feedback.rating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 18,
              color: AgrisellColors.authGreen,
            ),
          ),
        ),
      ),
      if (feedback.comment.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(feedback.comment, style: FarmerFeedbackCardStyles.textStyle2),
      ],
    ],
  );
}
