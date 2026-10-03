import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import '../styles/review_report_appeal_styles.dart';
import '../utils/review_report_appeal_config.dart';
import 'review_report_appeal_actions.dart';
import 'review_report_appeal_context_card.dart';
import 'review_report_appeal_details_input.dart';
import 'review_report_appeal_header.dart';
import 'review_report_appeal_reason_picker.dart';

class ReviewReportAppealSheet extends StatefulWidget {
  const ReviewReportAppealSheet({
    required this.review,
    required this.actionType,
    required this.onSubmit,
    super.key,
  });

  final FarmerReview review;
  final String actionType; // 'report' or 'appeal'
  final Future<bool> Function({
    required String reason,
    String? details,
  }) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required FarmerReview review,
    required String actionType,
    required Future<bool> Function({
      required String reason,
      String? details,
    }) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewReportAppealSheet(
        review: review,
        actionType: actionType,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReviewReportAppealSheet> createState() =>
      _ReviewReportAppealSheetState();
}

class _ReviewReportAppealSheetState extends State<ReviewReportAppealSheet> {
  late final ReviewReportAppealConfig _config;
  late String _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _config = ReviewReportAppealConfig.fromActionType(widget.actionType);
    _selectedReason = _config.reasons.first;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleFormSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await widget.onSubmit(
      reason: _selectedReason,
      details: _detailsController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = _config.submitErrorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight =
        MediaQuery.of(context).size.height *
        ReviewReportAppealStyles.maxSheetHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: ReviewReportAppealStyles.sheetDecoration,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReviewReportAppealHeader(
              config: _config,
              onClose: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(false),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: ReviewReportAppealStyles.bodyPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewReportAppealContextCard(review: widget.review),
                    const SizedBox(height: ReviewReportAppealStyles.sectionGap),
                    ReviewReportAppealReasonPicker(
                      title: _config.reasonSectionTitle,
                      reasons: _config.reasons,
                      selectedReason: _selectedReason,
                      primaryColor: _config.primaryColor,
                      enabled: !_isSubmitting,
                      onChanged: (reason) {
                        setState(() => _selectedReason = reason);
                      },
                    ),
                    const SizedBox(height: ReviewReportAppealStyles.itemGap),
                    ReviewReportAppealDetailsInput(
                      title: _config.detailsSectionTitle,
                      hintText: _config.detailsHint,
                      controller: _detailsController,
                      enabled: !_isSubmitting,
                      primaryColor: _config.primaryColor,
                      errorMessage: _errorMessage,
                    ),
                  ],
                ),
              ),
            ),
            ReviewReportAppealActions(
              isSubmitting: _isSubmitting,
              submitLabel: _config.submitButtonLabel,
              primaryColor: _config.primaryColor,
              onCancel: () => Navigator.of(context).pop(false),
              onSubmit: _handleFormSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
