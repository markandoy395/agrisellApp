import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/reviews/data/farmer_reviews_repository.dart';
import 'package:agresell_app/features/farmer/reviews/data/supabase_farmer_reviews_repository.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';

enum FarmerReviewsFilter {
  all,
  fiveStar,
  fourStar,
  threeStar,
  twoStar,
  oneStar,
  withNotes;

  String get label => switch (this) {
    FarmerReviewsFilter.all => 'All',
    FarmerReviewsFilter.fiveStar => '5 ★',
    FarmerReviewsFilter.fourStar => '4 ★',
    FarmerReviewsFilter.threeStar => '3 ★',
    FarmerReviewsFilter.twoStar => '2 ★',
    FarmerReviewsFilter.oneStar => '1 ★',
    FarmerReviewsFilter.withNotes => 'With Admin Notes',
  };
}

class FarmerReviewsController extends ChangeNotifier {
  FarmerReviewsController({FarmerReviewsRepository? repository})
      : _repository = repository ?? _defaultRepository();

  final FarmerReviewsRepository _repository;

  FarmerReviewsData _data = const FarmerReviewsData.empty();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  FarmerReviewsFilter _filter = FarmerReviewsFilter.all;
  String _searchQuery = '';

  FarmerReviewsData get data => _data;
  FarmerRatingsSummary get summary => _data.summary;
  List<FarmerReview> get allReviews => _data.reviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  FarmerReviewsFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<FarmerReview> get filteredReviews {
    var list = _data.reviews;

    // Apply category / rating filter
    list = switch (_filter) {
      FarmerReviewsFilter.all => list,
      FarmerReviewsFilter.fiveStar => list.where((r) => r.rating >= 4.5).toList(),
      FarmerReviewsFilter.fourStar =>
          list.where((r) => r.rating >= 3.5 && r.rating < 4.5).toList(),
      FarmerReviewsFilter.threeStar =>
          list.where((r) => r.rating >= 2.5 && r.rating < 3.5).toList(),
      FarmerReviewsFilter.twoStar =>
          list.where((r) => r.rating >= 1.5 && r.rating < 2.5).toList(),
      FarmerReviewsFilter.oneStar => list.where((r) => r.rating < 1.5).toList(),
      FarmerReviewsFilter.withNotes =>
          list.where((r) => r.hasAdminNote).toList(),
    };

    // Apply search filter
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((r) {
        final commodity = r.commodityName.toLowerCase();
        final buyer = r.buyerName.toLowerCase();
        final comment = (r.comment ?? '').toLowerCase();
        final order = r.clientOrderId.toLowerCase();
        final note = (r.adminModerationNote ?? '').toLowerCase();
        return commodity.contains(query) ||
            buyer.contains(query) ||
            comment.contains(query) ||
            order.contains(query) ||
            note.contains(query);
      }).toList();
    }

    return list;
  }

  void setFilter(FarmerReviewsFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadReviews({String? farmerId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _repository.fetchReviews(farmerId: farmerId);
    } catch (error) {
      _errorMessage = 'Could not load customer reviews: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReportOrAppeal({
    required String reviewId,
    required String actionType,
    required String reason,
    String? details,
    String? farmerId,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitReportOrAppeal(
        reviewId: reviewId,
        actionType: actionType,
        reason: reason,
        details: details,
      );
      await loadReviews(farmerId: farmerId);
      return true;
    } catch (error) {
      _errorMessage = 'Failed to submit $actionType: $error';
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  static FarmerReviewsRepository _defaultRepository() {
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      return SupabaseFarmerReviewsRepository();
    }
    return InMemoryFarmerReviewsRepository();
  }
}
