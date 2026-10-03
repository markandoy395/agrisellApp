import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/review_report_appeal_styles.dart';

class ReviewReportAppealActions extends StatelessWidget {
  const ReviewReportAppealActions({
    required this.isSubmitting,
    required this.submitLabel,
    required this.primaryColor,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  final bool isSubmitting;
  final String submitLabel;
  final Color primaryColor;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ReviewReportAppealStyles.footerPadding,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting ? null : onCancel,
              style: ReviewReportAppealStyles.cancelButtonStyle,
              child: const Text(
                'Cancel',
                style: ReviewReportAppealStyles.cancelButtonText,
              ),
            ),
          ),
          const SizedBox(width: ReviewReportAppealStyles.buttonGap),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ReviewReportAppealStyles.submitButtonStyle(primaryColor),
              child: isSubmitting
                  ? const SizedBox(
                      height: ReviewReportAppealStyles.loadingIndicatorSize,
                      width: ReviewReportAppealStyles.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth:
                            ReviewReportAppealStyles.loadingIndicatorStroke,
                        color: AgrisellColors.surface,
                      ),
                    )
                  : Text(
                      submitLabel,
                      style: ReviewReportAppealStyles.submitButtonText,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
