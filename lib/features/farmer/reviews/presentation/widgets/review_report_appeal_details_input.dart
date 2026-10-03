import 'package:flutter/material.dart';

import '../styles/review_report_appeal_styles.dart';

class ReviewReportAppealDetailsInput extends StatelessWidget {
  const ReviewReportAppealDetailsInput({
    required this.title,
    required this.hintText,
    required this.controller,
    required this.enabled,
    required this.primaryColor,
    this.errorMessage,
    super.key,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool enabled;
  final Color primaryColor;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ReviewReportAppealStyles.sectionTitle),
        const SizedBox(height: ReviewReportAppealStyles.commentGap),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 3,
          maxLength: 500,
          style: ReviewReportAppealStyles.inputText,
          decoration: ReviewReportAppealStyles.inputDecoration(
            primaryColor: primaryColor,
            hintText: hintText,
          ),
        ),
        if (errorMessage != null)
          Container(
            margin: ReviewReportAppealStyles.errorMargin,
            padding: ReviewReportAppealStyles.errorPadding,
            decoration: ReviewReportAppealStyles.errorBannerDecoration,
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: ReviewReportAppealStyles.errorIconSize,
                  color: ReviewReportAppealStyles.errorIconColor,
                ),
                const SizedBox(width: ReviewReportAppealStyles.errorContentGap),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: ReviewReportAppealStyles.errorText,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
