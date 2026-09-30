class ProductReview {
  const ProductReview({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.submittedAt,
    this.adminResponse,
    this.adminRespondedAt,
    this.moderationNote,
    this.moderationStatus,
  });

  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime? submittedAt;
  final String? adminResponse;
  final DateTime? adminRespondedAt;
  final String? moderationNote;
  final String? moderationStatus;
}

class ProductReviewSummary {
  const ProductReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  const ProductReviewSummary.empty()
    : averageRating = 0,
      reviewCount = 0,
      reviews = const [];

  final double averageRating;
  final int reviewCount;
  final List<ProductReview> reviews;
}
