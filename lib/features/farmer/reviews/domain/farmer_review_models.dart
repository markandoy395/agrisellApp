part 'farmer_ratings_summary.dart';

class FarmerReview {
  const FarmerReview({
    required this.id,
    required this.orderId,
    required this.clientOrderId,
    required this.commodityId,
    required this.commodityName,
    this.commodityImageUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.buyerName,
    this.visibilityStatus = 'published',
    this.reportStatus = 'none',
    this.abuseFlags = const [],
    this.adminModerationNote,
    this.adminResponse,
    this.adminResponseMode,
    this.adminRespondedAt,
  }) : assert(id != ''),
       assert(rating >= 1.0 && rating <= 5.0);

  final String id;
  final int orderId;
  final String clientOrderId;
  final int commodityId;
  final String commodityName;
  final String? commodityImageUrl;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String buyerName;
  final String visibilityStatus;
  final String reportStatus;
  final List<String> abuseFlags;
  final String? adminModerationNote;
  final String? adminResponse;
  final String? adminResponseMode;
  final DateTime? adminRespondedAt;

  bool get hasAdminNote =>
      adminModerationNote != null && adminModerationNote!.trim().isNotEmpty;

  bool get isHidden => visibilityStatus.trim().toLowerCase() == 'hidden';

  bool get isReportOpen => reportStatus.trim().toLowerCase() == 'open';

  bool get isReported => isReportOpen;

  bool get isFlagged => abuseFlags.isNotEmpty || isReported;

  bool get hasAdminResponse =>
      adminResponse != null && adminResponse!.trim().isNotEmpty;

  bool get canReport => !isReportOpen;

  bool get canAppeal => (isHidden || isFlagged || hasAdminNote) && !isReportOpen;

  static const List<String> reportReasons = [
    'Spam or Promotion',
    'Malicious or Competitor Attack',
    'Harassment or Abusive Language',
    'False or Misleading Claims',
    'Other Policy Violation',
  ];

  static const List<String> appealGrounds = [
    'Legitimate Customer Feedback',
    'Dispute Resolved with Buyer',
    'Incorrect Abuse Flagging',
    'Clarification / Evidence Provided',
    'Other Grounds',
  ];

  FarmerReview copyWith({
    String? id,
    int? orderId,
    String? clientOrderId,
    int? commodityId,
    String? commodityName,
    String? commodityImageUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? buyerName,
    String? visibilityStatus,
    String? reportStatus,
    List<String>? abuseFlags,
    String? adminModerationNote,
    String? adminResponse,
    String? adminResponseMode,
    DateTime? adminRespondedAt,
  }) {
    return FarmerReview(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      clientOrderId: clientOrderId ?? this.clientOrderId,
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      commodityImageUrl: commodityImageUrl ?? this.commodityImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      buyerName: buyerName ?? this.buyerName,
      visibilityStatus: visibilityStatus ?? this.visibilityStatus,
      reportStatus: reportStatus ?? this.reportStatus,
      abuseFlags: abuseFlags ?? this.abuseFlags,
      adminModerationNote: adminModerationNote ?? this.adminModerationNote,
      adminResponse: adminResponse ?? this.adminResponse,
      adminResponseMode: adminResponseMode ?? this.adminResponseMode,
      adminRespondedAt: adminRespondedAt ?? this.adminRespondedAt,
    );
  }

  factory FarmerReview.fromJson(Map<String, dynamic> json) {
    final flags = json['abuse_flags'];
    final List<String> parsedFlags = flags is List
        ? flags.map((f) => f.toString()).toList()
        : const [];

    return FarmerReview(
      id: json['review_id']?.toString() ?? '',
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      clientOrderId: json['client_order_id']?.toString() ?? 'AG-${json['order_id']}',
      commodityId: (json['commodity_id'] as num?)?.toInt() ?? 0,
      commodityName: json['commodity_name']?.toString() ?? 'Agricultural Product',
      commodityImageUrl: json['commodity_image_url']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      buyerName: json['buyer_name']?.toString() ?? 'Verified Buyer',
      visibilityStatus: json['visibility_status']?.toString() ?? 'published',
      reportStatus: json['report_status']?.toString() ?? 'none',
      abuseFlags: parsedFlags,
      adminModerationNote: json['admin_moderation_note']?.toString(),
      adminResponse: json['admin_response']?.toString(),
      adminResponseMode: json['admin_response_mode']?.toString(),
      adminRespondedAt: json['admin_responded_at'] != null
          ? DateTime.tryParse(json['admin_responded_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'review_id': id,
    'order_id': orderId,
    'client_order_id': clientOrderId,
    'commodity_id': commodityId,
    'commodity_name': commodityName,
    'commodity_image_url': commodityImageUrl,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'buyer_name': buyerName,
    'visibility_status': visibilityStatus,
    'report_status': reportStatus,
    'abuse_flags': abuseFlags,
    'admin_moderation_note': adminModerationNote,
    'admin_response': adminResponse,
    'admin_response_mode': adminResponseMode,
    'admin_responded_at': adminRespondedAt?.toIso8601String(),
  };
}
