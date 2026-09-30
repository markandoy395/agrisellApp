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

class FarmerRatingsSummary {
  const FarmerRatingsSummary({
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
    this.moderatedCount = 0,
  }) : assert(averageRating >= 0.0 && averageRating <= 5.0),
       assert(totalReviews >= 0);

  const FarmerRatingsSummary.empty() : this();

  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final int moderatedCount;

  bool get isEmpty => totalReviews == 0;

  double get fiveStarPercent =>
      totalReviews > 0 ? (fiveStarCount * 100.0) / totalReviews : 0.0;
  double get fourStarPercent =>
      totalReviews > 0 ? (fourStarCount * 100.0) / totalReviews : 0.0;
  double get threeStarPercent =>
      totalReviews > 0 ? (threeStarCount * 100.0) / totalReviews : 0.0;
  double get twoStarPercent =>
      totalReviews > 0 ? (twoStarCount * 100.0) / totalReviews : 0.0;
  double get oneStarPercent =>
      totalReviews > 0 ? (oneStarCount * 100.0) / totalReviews : 0.0;

  factory FarmerRatingsSummary.fromJson(Map<String, dynamic> json) {
    return FarmerRatingsSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      fiveStarCount: (json['five_star_count'] as num?)?.toInt() ?? 0,
      fourStarCount: (json['four_star_count'] as num?)?.toInt() ?? 0,
      threeStarCount: (json['three_star_count'] as num?)?.toInt() ?? 0,
      twoStarCount: (json['two_star_count'] as num?)?.toInt() ?? 0,
      oneStarCount: (json['one_star_count'] as num?)?.toInt() ?? 0,
      moderatedCount: (json['moderated_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'five_star_count': fiveStarCount,
    'four_star_count': fourStarCount,
    'three_star_count': threeStarCount,
    'two_star_count': twoStarCount,
    'one_star_count': oneStarCount,
    'moderated_count': moderatedCount,
  };
}

class FarmerReviewsData {
  const FarmerReviewsData({
    required this.summary,
    this.reviews = const <FarmerReview>[],
  });

  const FarmerReviewsData.empty()
      : summary = const FarmerRatingsSummary.empty(),
        reviews = const <FarmerReview>[];

  final FarmerRatingsSummary summary;
  final List<FarmerReview> reviews;

  bool get hasData => !summary.isEmpty || reviews.isNotEmpty;
}
