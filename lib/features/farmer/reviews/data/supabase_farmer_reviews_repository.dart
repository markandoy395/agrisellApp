import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/reviews/data/farmer_reviews_repository.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';

class SupabaseFarmerReviewsRepository implements FarmerReviewsRepository {
  SupabaseFarmerReviewsRepository({SupabaseClient? client})
      : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  @override
  Future<FarmerReviewsData> fetchReviews({String? farmerId}) async {
    try {
      final response = await _client.rpc<Object?>('current_farmer_reviews');
      if (response == null) {
        return const FarmerReviewsData.empty();
      }

      final Map<String, dynamic> data;
      if (response is Map<String, dynamic>) {
        data = response;
      } else if (response is Map) {
        data = Map<String, dynamic>.from(response);
      } else {
        return const FarmerReviewsData.empty();
      }

      final summaryMap = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'] as Map)
          : <String, dynamic>{};
      final summary = FarmerRatingsSummary.fromJson(summaryMap);

      final rawReviews = data['reviews'];
      final List<FarmerReview> reviews;
      if (rawReviews is List) {
        reviews = rawReviews
            .whereType<Map>()
            .map((r) => FarmerReview.fromJson(Map<String, dynamic>.from(r)))
            .toList(growable: false);
      } else {
        reviews = const [];
      }

      return FarmerReviewsData(summary: summary, reviews: reviews);
    } catch (error) {
      throw Exception('Failed to load farmer reviews: $error');
    }
  }

  @override
  Future<void> submitReportOrAppeal({
    required String reviewId,
    required String actionType,
    required String reason,
    String? details,
  }) async {
    try {
      final parsedId = int.tryParse(reviewId);
      if (parsedId == null || parsedId <= 0) {
        throw Exception('Invalid review ID');
      }

      await _client.rpc<dynamic>(
        'submit_farmer_review_report_or_appeal',
        params: {
          'p_review_id': parsedId,
          'p_action_type': actionType,
          'p_reason': reason,
          'p_details': details,
        },
      );
    } catch (error) {
      throw Exception('Failed to submit $actionType: $error');
    }
  }
}
