import 'package:flutter/material.dart';

import '../styles/review_report_appeal_styles.dart';

class ReviewReportAppealReasonPicker extends StatelessWidget {
  const ReviewReportAppealReasonPicker({
    required this.title,
    required this.reasons,
    required this.selectedReason,
    required this.primaryColor,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String title;
  final List<String> reasons;
  final String selectedReason;
  final Color primaryColor;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ReviewReportAppealStyles.sectionTitle),
        const SizedBox(height: ReviewReportAppealStyles.titleGap),
        ...reasons.map((option) {
          final isSelected = option == selectedReason;
          return Padding(
            padding: ReviewReportAppealStyles.optionItemMargin,
            child: InkWell(
              onTap: enabled ? () => onChanged(option) : null,
              borderRadius: ReviewReportAppealStyles.optionRadius,
              child: Container(
                padding: ReviewReportAppealStyles.optionContentPadding,
                decoration: ReviewReportAppealStyles.optionDecoration(
                  isSelected: isSelected,
                  primaryColor: primaryColor,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? primaryColor
                          : ReviewReportAppealStyles.optionUnselectedIcon,
                      size: ReviewReportAppealStyles.optionIconSize,
                    ),
                    const SizedBox(width: ReviewReportAppealStyles.optionIconGap),
                    Expanded(
                      child: Text(
                        option,
                        style: ReviewReportAppealStyles.optionTextStyle(
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
