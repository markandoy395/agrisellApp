import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';

abstract class FarmerReviewsRepository {
  Future<FarmerReviewsData> fetchReviews({String? farmerId});
  Future<void> submitReportOrAppeal({
    required String reviewId,
    required String actionType,
    required String reason,
    String? details,
  });
}

class InMemoryFarmerReviewsRepository implements FarmerReviewsRepository {
  InMemoryFarmerReviewsRepository({FarmerReviewsData? initialData})
      : _data = initialData ?? _defaultSeedData();

  FarmerReviewsData _data;

  void setData(FarmerReviewsData data) {
    _data = data;
  }

  @override
  Future<FarmerReviewsData> fetchReviews({String? farmerId}) async {
    return _data;
  }

  @override
  Future<void> submitReportOrAppeal({
    required String reviewId,
    required String actionType,
    required String reason,
    String? details,
  }) async {
    final updatedReviews = _data.reviews.map((r) {
      if (r.id == reviewId) {
        final note = (actionType == 'appeal' ? 'Farmer Appeal: [' : 'Farmer Report: [') +
            reason +
            ']' +
            (details != null && details.trim().isNotEmpty ? ' - ${details.trim()}' : '');
        return r.copyWith(
          reportStatus: 'open',
          adminModerationNote: note,
        );
      }
      return r;
    }).toList();

    _data = FarmerReviewsData(
      summary: _data.summary,
      reviews: updatedReviews,
    );
  }

  static FarmerReviewsData _defaultSeedData() {
    final now = DateTime.now();
    final reviews = <FarmerReview>[
      FarmerReview(
        id: 'rev-101',
        orderId: 1001,
        clientOrderId: 'AG-1001',
        commodityId: 501,
        commodityName: 'Fresh Benguet Tomatoes',
        rating: 5.0,
        comment: 'Super fresh and well-packed! Arrived crisp and undamaged.',
        createdAt: now.subtract(const Duration(hours: 4)),
        buyerName: 'Maria S.',
        visibilityStatus: 'published',
        reportStatus: 'none',
      ),
      FarmerReview(
        id: 'rev-102',
        orderId: 1002,
        clientOrderId: 'AG-1002',
        commodityId: 502,
        commodityName: 'Organic Highland Lettuce',
        rating: 4.0,
        comment: 'Crisp leaves, clean produce. Packaging could use slightly more ventilation.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        buyerName: 'Carlos M.',
        visibilityStatus: 'published',
        reportStatus: 'none',
      ),
      FarmerReview(
        id: 'rev-103',
        orderId: 1003,
        clientOrderId: 'AG-1003',
        commodityId: 503,
        commodityName: 'Sweet Strawberries 500g',
        rating: 3.0,
        comment: 'Taste is sweet, but a couple were slightly bruised at the bottom of the box.',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        buyerName: 'Elena R.',
        visibilityStatus: 'published',
        reportStatus: 'resolved',
        abuseFlags: const ['other'],
        adminModerationNote:
            'Reviewed by Support: Transit vibration issue investigated. Payout verified and packaging cushion guidelines shared with farmer.',
        adminResponse:
            'Agrisell Customer Care contacted the buyer and issued a partial produce voucher. Produce handling feedback has been logged.',
        adminResponseMode: 'public',
        adminRespondedAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      FarmerReview(
        id: 'rev-104',
        orderId: 1004,
        clientOrderId: 'AG-1004',
        commodityId: 504,
        commodityName: 'Baguio Carrots 1kg',
        rating: 5.0,
        comment: 'Top quality carrots, vibrant color and sweet crunch. Will definitely reorder!',
        createdAt: now.subtract(const Duration(days: 4)),
        buyerName: 'Jonathan D.',
        visibilityStatus: 'published',
        reportStatus: 'none',
      ),
      FarmerReview(
        id: 'rev-105',
        orderId: 1005,
        clientOrderId: 'AG-1005',
        commodityId: 505,
        commodityName: 'Native Garlic 500g',
        rating: 5.0,
        comment: 'Aromatic and very flavorful. Great harvest quality.',
        createdAt: now.subtract(const Duration(days: 6)),
        buyerName: 'Grace L.',
        visibilityStatus: 'published',
        reportStatus: 'none',
      ),
    ];

    return FarmerReviewsData(
      summary: const FarmerRatingsSummary(
        averageRating: 4.4,
        totalReviews: 5,
        fiveStarCount: 3,
        fourStarCount: 1,
        threeStarCount: 1,
        twoStarCount: 0,
        oneStarCount: 0,
        moderatedCount: 1,
      ),
      reviews: reviews,
    );
  }
}
