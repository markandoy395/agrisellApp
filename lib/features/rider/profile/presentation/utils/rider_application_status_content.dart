import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

/// Preserves legacy pending fallbacks and admin-review precedence.
class RiderApplicationStatusContent {
  const RiderApplicationStatusContent({this.details, this.isPending = true});
  final RiderVerificationDetails? details;
  final bool isPending;

  bool get isNeedsInfo => details?.isNeedsInformation ?? false;
  bool get isRejected => details?.isRejected ?? !isPending;
  bool get isApproved => details?.isVerified ?? false;

  String get title {
    if (isApproved) return 'Application approved';
    if (isNeedsInfo) return 'Information requested';
    if (isRejected) return 'Application not approved';
    return 'Pending verification';
  }

  String get description {
    if (isApproved) {
      return 'Your rider account has been approved and is ready for delivery work.';
    }
    if (isNeedsInfo) {
      return 'The admin review team requested additional information or document updates before your account can be approved.';
    }
    if (isRejected) {
      return 'Your application was reviewed and could not be approved at this time. Please see details below.';
    }
    return 'Your information and documents are waiting for review.';
  }

  String get nextStepsTitle {
    if (isNeedsInfo) return 'What should I do now?';
    if (isRejected) return 'Need assistance?';
    return 'What happens next?';
  }

  String get nextStepsDescription {
    if (isNeedsInfo) {
      return 'Please prepare the requested documents and information listed above. Once ready, reach out to our team or update your profile to continue.';
    }
    if (isRejected) {
      return 'Our support team can explain the decision or guide you through submitting an updated application.';
    }
    return 'We will notify you when your account is ready to be activated.';
  }
}

String formatRiderReviewDate(DateTime date) {
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
