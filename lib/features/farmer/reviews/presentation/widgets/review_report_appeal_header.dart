import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/review_report_appeal_styles.dart';
import '../utils/review_report_appeal_config.dart';

class ReviewReportAppealHeader extends StatelessWidget {
  const ReviewReportAppealHeader({
    required this.config,
    this.onClose,
    super.key,
  });

  final ReviewReportAppealConfig config;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: ReviewReportAppealStyles.handleBarMargin,
            width: ReviewReportAppealStyles.handleBarWidth,
            height: ReviewReportAppealStyles.handleBarHeight,
            decoration: ReviewReportAppealStyles.handleBarDecoration,
          ),
        ),
        Padding(
          padding: ReviewReportAppealStyles.headerPadding,
          child: Row(
            children: [
              Container(
                padding: ReviewReportAppealStyles.headerIconPadding,
                decoration: ReviewReportAppealStyles.headerIconDecoration(
                  config.primaryColor,
                ),
                child: Icon(
                  config.headerIcon,
                  color: config.primaryColor,
                  size: ReviewReportAppealStyles.headerIconSize,
                ),
              ),
              const SizedBox(width: ReviewReportAppealStyles.headerGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.headerTitle,
                      style: ReviewReportAppealStyles.headerTitle,
                    ),
                    const SizedBox(height: ReviewReportAppealStyles.subtitleGap),
                    Text(
                      config.headerSubtitle,
                      style: ReviewReportAppealStyles.headerSubtitle,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AgrisellColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: ReviewReportAppealStyles.dividerColor),
      ],
    );
  }
}
