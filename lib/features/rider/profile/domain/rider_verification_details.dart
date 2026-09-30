import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';

class RiderVerificationDetails {
  const RiderVerificationDetails({
    required this.reference,
    required this.verificationStatus,
    this.action,
    this.reason,
    this.message,
    this.missingItems = const [],
    this.reviewedAt,
    this.documents = const [],
  });

  final String reference;
  final RiderVerificationStatus verificationStatus;
  final String? action;
  final String? reason;
  final String? message;
  final List<String> missingItems;
  final DateTime? reviewedAt;
  final List<RiderVerificationDocumentItem> documents;

  bool get isNeedsInformation => action == 'needs_information';

  bool get isRejected =>
      verificationStatus == RiderVerificationStatus.rejected ||
      action == 'rejected';

  bool get isVerified =>
      verificationStatus == RiderVerificationStatus.verified ||
      action == 'verified';

  bool get isPending => !isNeedsInformation && !isRejected && !isVerified;

  bool get hasRejectionReason => reason != null && reason!.trim().isNotEmpty;

  bool get hasMessage => message != null && message!.trim().isNotEmpty;

  bool get hasMissingItems => missingItems.isNotEmpty;

  bool get hasRejectedDocuments => rejectedDocuments.isNotEmpty;

  List<RiderVerificationDocumentItem> get rejectedDocuments => documents
      .where(
        (doc) =>
            doc.isRejected ||
            (doc.rejectionReason != null &&
                doc.rejectionReason!.trim().isNotEmpty),
      )
      .toList();

  factory RiderVerificationDetails.fromJson(
    Map<String, Object?> json, {
    String? fallbackReference,
  }) {
    final ref = _text(json['rider_id'], fallback: fallbackReference ?? '');
    final statusStr = _optionalText(json['verification_status']);
    final verificationStatus = statusStr != null
        ? RiderVerificationStatus.fromDatabaseValue(statusStr)
        : RiderVerificationStatus.pending;

    final action = _optionalText(json['action']);
    final reason = _optionalText(json['reason']);
    final message = _optionalText(json['message']);

    final rawMissing = json['missing_items'];
    final missingItems = <String>[];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        if (item != null) {
          final s = item.toString().trim();
          if (s.isNotEmpty) missingItems.add(s);
        }
      }
    }

    DateTime? reviewedAt;
    final rawReviewedAt = json['reviewed_at'];
    if (rawReviewedAt is String && rawReviewedAt.isNotEmpty) {
      reviewedAt = DateTime.tryParse(rawReviewedAt);
    }

    final rawDocs = json['documents'];
    final docs = <RiderVerificationDocumentItem>[];
    if (rawDocs is List) {
      for (final item in rawDocs) {
        if (item is Map<String, Object?>) {
          docs.add(RiderVerificationDocumentItem.fromJson(item));
        } else if (item is Map) {
          docs.add(
            RiderVerificationDocumentItem.fromJson(
              item.cast<String, Object?>(),
            ),
          );
        }
      }
    }

    return RiderVerificationDetails(
      reference: ref,
      verificationStatus: verificationStatus,
      action: action,
      reason: reason,
      message: message,
      missingItems: List.unmodifiable(missingItems),
      reviewedAt: reviewedAt,
      documents: List.unmodifiable(docs),
    );
  }

  static String _text(Object? value, {String fallback = ''}) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  static String? _optionalText(Object? value) {
    final s = value?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }
}

class RiderVerificationDocumentItem {
  const RiderVerificationDocumentItem({
    required this.documentId,
    required this.documentType,
    this.documentNumber,
    this.verificationStatus = RiderDocumentVerificationStatus.pending,
    this.rejectionReason,
    this.updatedAt,
  });

  final String documentId;
  final RiderDocumentType documentType;
  final String? documentNumber;
  final RiderDocumentVerificationStatus verificationStatus;
  final String? rejectionReason;
  final DateTime? updatedAt;

  bool get isRejected =>
      verificationStatus == RiderDocumentVerificationStatus.rejected;

  bool get isVerified =>
      verificationStatus == RiderDocumentVerificationStatus.verified;

  bool get isPending =>
      verificationStatus == RiderDocumentVerificationStatus.pending;

  String get displayName => switch (documentType) {
    RiderDocumentType.driversLicense => "Driver's License",
    RiderDocumentType.validId => 'Government-Issued ID',
    RiderDocumentType.profileSelfie => 'Profile Photo / Selfie',
    RiderDocumentType.vehicleOr => 'Vehicle Official Receipt (OR)',
    RiderDocumentType.vehicleCr => 'Vehicle Certificate of Registration (CR)',
    RiderDocumentType.vehiclePhoto => 'Vehicle Photo',
  };

  factory RiderVerificationDocumentItem.fromJson(Map<String, Object?> json) {
    final docTypeStr = json['document_type']?.toString();
    RiderDocumentType docType;
    try {
      docType = RiderDocumentType.parse(docTypeStr);
    } catch (_) {
      docType = RiderDocumentType.validId;
    }

    final statusStr = json['verification_status']?.toString();
    final status = RiderDocumentVerificationStatus.values.firstWhere(
      (item) => item.name == statusStr,
      orElse: () => RiderDocumentVerificationStatus.pending,
    );

    DateTime? updatedAt;
    final rawDate = json['updated_at'];
    if (rawDate is String && rawDate.isNotEmpty) {
      updatedAt = DateTime.tryParse(rawDate);
    }

    final reason = json['rejection_reason']?.toString().trim();

    return RiderVerificationDocumentItem(
      documentId: json['document_id']?.toString() ?? '',
      documentType: docType,
      documentNumber: json['document_number']?.toString().trim(),
      verificationStatus: status,
      rejectionReason: (reason == null || reason.isEmpty) ? null : reason,
      updatedAt: updatedAt,
    );
  }
}
