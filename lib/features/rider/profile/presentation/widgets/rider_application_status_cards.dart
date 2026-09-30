import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

class RiderApplicationReferenceCard extends StatelessWidget {
  const RiderApplicationReferenceCard({required this.reference, super.key});
  final String reference;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPLICATION REFERENCE',
          style: TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          reference,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class RiderApplicationStatusCard extends StatelessWidget {
  const RiderApplicationStatusCard({
    this.isPending = true,
    this.details,
    super.key,
  });

  final bool isPending;
  final RiderVerificationDetails? details;

  bool get _isNeedsInfo => details?.isNeedsInformation ?? false;
  bool get _isRejected => details?.isRejected ?? !isPending;
  bool get _isApproved => details?.isVerified ?? false;

  Color get _statusColor {
    if (_isApproved) return AgrisellColors.statusGreenText;
    if (_isNeedsInfo) return AgrisellColors.statusOrangeText;
    if (_isRejected) return AgrisellColors.statusRedText;
    return AgrisellColors.statusOrangeText;
  }

  Color get _statusBackground {
    if (_isApproved) return AgrisellColors.statusGreenBackground;
    if (_isNeedsInfo) return AgrisellColors.statusOrangeBackground;
    if (_isRejected) return AgrisellColors.statusRedBackground;
    return AgrisellColors.statusOrangeBackground;
  }

  IconData get _statusIcon {
    if (_isApproved) return Icons.check_circle_rounded;
    if (_isNeedsInfo) return Icons.assignment_late_rounded;
    if (_isRejected) return Icons.cancel_rounded;
    return Icons.hourglass_top_rounded;
  }

  String get _title {
    if (_isApproved) return 'Application approved';
    if (_isNeedsInfo) return 'Information requested';
    if (_isRejected) return 'Application not approved';
    return 'Pending verification';
  }

  String get _description {
    if (_isApproved) {
      return 'Your rider account has been approved and is ready for delivery work.';
    }
    if (_isNeedsInfo) {
      return 'The admin review team requested additional information or document updates before your account can be approved.';
    }
    if (_isRejected) {
      return 'Your application was reviewed and could not be approved at this time. Please see details below.';
    }
    return 'Your information and documents are waiting for review.';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[date.month - 1];
    final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$m ${date.day}, ${date.year} at $h:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _statusBackground,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _statusColor.withValues(alpha: .24)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AgrisellColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_statusIcon, color: _statusColor, size: 24),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _description,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              if (details?.reviewedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reviewed on ${_formatDate(details!.reviewedAt!)}',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderVerificationFeedbackCard extends StatelessWidget {
  const RiderVerificationFeedbackCard({required this.details, super.key});

  final RiderVerificationDetails details;

  @override
  Widget build(BuildContext context) {
    final hasReason = details.hasRejectionReason;
    final hasMessage = details.hasMessage;
    final hasMissing = details.hasMissingItems;

    if (!hasReason && !hasMessage && !hasMissing) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: AgrisellColors.forestGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'ADMIN REVIEW FEEDBACK',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Overall Rejection Reason
          if (hasReason) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgrisellColors.statusRedBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AgrisellColors.statusRedText.withValues(alpha: .24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AgrisellColors.statusRedText,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'REJECTION REASON',
                        style: TextStyle(
                          color: AgrisellColors.statusRedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details.reason!,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasMessage || hasMissing) const SizedBox(height: 12),
          ],

          // 2. Note from Reviewer
          if (hasMessage) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgrisellColors.statusOrangeBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AgrisellColors.statusOrangeText.withValues(alpha: .24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: AgrisellColors.statusOrangeText,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'NOTE FROM REVIEWER',
                        style: TextStyle(
                          color: AgrisellColors.statusOrangeText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details.message!,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (hasMissing) const SizedBox(height: 12),
          ],

          // 3. Information Requested Checklist
          if (hasMissing) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgrisellColors.homeBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AgrisellColors.borderLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 18,
                        color: AgrisellColors.statusOrangeText,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'MISSING OR REQUESTED ITEMS',
                        style: TextStyle(
                          color: AgrisellColors.statusOrangeText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The reviewer specifically requested updates on the following items:',
                    style: TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.missingItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_box_outline_blank_rounded,
                            size: 16,
                            color: AgrisellColors.statusOrangeText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: AgrisellColors.headingGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RiderRejectedDocumentsCard extends StatelessWidget {
  const RiderRejectedDocumentsCard({required this.details, super.key});

  final RiderVerificationDetails details;

  @override
  Widget build(BuildContext context) {
    final rejectedDocs = details.rejectedDocuments;
    if (rejectedDocs.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.folder_off_outlined,
                color: AgrisellColors.statusRedText,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'DOCUMENT FEEDBACK',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'The following documents require attention or re-submission:',
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...rejectedDocs.map((doc) => _DocumentItem(doc: doc)),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({required this.doc});

  final RiderVerificationDocumentItem doc;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AgrisellColors.homeBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: AgrisellColors.statusRedText.withValues(alpha: .2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              size: 18,
              color: AgrisellColors.headingGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                doc.displayName,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AgrisellColors.statusRedBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AgrisellColors.statusRedText.withValues(alpha: .24),
                ),
              ),
              child: const Text(
                'Rejected',
                style: TextStyle(
                  color: AgrisellColors.statusRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Number: ${doc.documentNumber}',
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
        if (doc.rejectionReason != null &&
            doc.rejectionReason!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AgrisellColors.statusRedBackground.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AgrisellColors.statusRedText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    doc.rejectionReason!,
                    style: const TextStyle(
                      color: AgrisellColors.statusRedText,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class RiderApplicationNextStepsCard extends StatelessWidget {
  const RiderApplicationNextStepsCard({
    this.isPending = true,
    this.details,
    super.key,
  });

  final bool isPending;
  final RiderVerificationDetails? details;

  bool get _isNeedsInfo => details?.isNeedsInformation ?? false;
  bool get _isRejected => details?.isRejected ?? !isPending;

  String get _title {
    if (_isNeedsInfo) return 'What should I do now?';
    if (_isRejected) return 'Need assistance?';
    return 'What happens next?';
  }

  String get _description {
    if (_isNeedsInfo) {
      return 'Please prepare the requested documents and information listed above. Once ready, reach out to our team or update your profile to continue.';
    }
    if (_isRejected) {
      return 'Our support team can explain the decision or guide you through submitting an updated application.';
    }
    return 'We will notify you when your account is ready to be activated.';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AgrisellColors.forestGreen,
          size: 21,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _description,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
