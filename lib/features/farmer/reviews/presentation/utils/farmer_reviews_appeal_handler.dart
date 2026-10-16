import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/review_report_appeal_sheet.dart';

/// Helper to handle report and appeal submissions for reviews.
abstract final class FarmerReviewsAppealHandler {
  static Future<void> handleReport({
    required BuildContext context,
    required FarmerReview review,
    required FarmerReviewsController controller,
    String? farmerId,
  }) async {
    final submitted = await ReviewReportAppealSheet.show(
      context,
      review: review,
      actionType: 'report',
      onSubmit: ({required reason, details}) async {
        return controller.submitReportOrAppeal(
          reviewId: review.id,
          actionType: 'report',
          reason: reason,
          details: details,
          farmerId: farmerId,
        );
      },
    );

    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
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

  static Future<void> handleAppeal({
    required BuildContext context,
    required FarmerReview review,
    required FarmerReviewsController controller,
    String? farmerId,
  }) async {
    final submitted = await ReviewReportAppealSheet.show(
      context,
      review: review,
      actionType: 'appeal',
      onSubmit: ({required reason, details}) async {
        return controller.submitReportOrAppeal(
          reviewId: review.id,
          actionType: 'appeal',
          reason: reason,
          details: details,
          farmerId: farmerId,
        );
      },
    );

    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
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
