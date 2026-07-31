import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';

enum RiderAnalyticsLoadState { idle, loading, ready, error }

class RiderAnalyticsController extends ChangeNotifier {
  RiderAnalyticsController({RiderAnalyticsRepository? repository})
    : _repository = repository ?? _defaultAnalyticsRepository();

  final RiderAnalyticsRepository _repository;
  var _earningsState = RiderAnalyticsLoadState.idle;
  var _historyState = RiderAnalyticsLoadState.idle;
  var _ratingsState = RiderAnalyticsLoadState.idle;
  RiderEarningsData _earnings = const RiderEarningsData.empty();
  List<RiderDeliveryHistoryEntry> _history = const [];
  RiderRatingsData _ratings = const RiderRatingsData.empty();
  String? _earningsError;
  String? _historyError;
  String? _ratingsError;

  RiderAnalyticsLoadState get earningsState => _earningsState;
  RiderAnalyticsLoadState get historyState => _historyState;
  RiderAnalyticsLoadState get ratingsState => _ratingsState;
  RiderEarningsData get earnings => _earnings;
  List<RiderDeliveryHistoryEntry> get history => List.unmodifiable(_history);
  RiderRatingsData get ratings => _ratings;
  String? get earningsError => _earningsError;
  String? get historyError => _historyError;
  String? get ratingsError => _ratingsError;

  Future<void> loadEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  }) async {
    _earningsState = RiderAnalyticsLoadState.loading;
    _earningsError = null;
    notifyListeners();
    try {
      _earnings = await _repository.fetchEarnings(
        riderId: riderId,
        dateRange: dateRange,
      );
      _earningsState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      _earningsState = RiderAnalyticsLoadState.error;
      _earningsError = 'Earnings could not be loaded.';
    }
    notifyListeners();
  }

  Future<void> loadHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  }) async {
    _historyState = RiderAnalyticsLoadState.loading;
    _historyError = null;
    notifyListeners();
    try {
      _history = List.unmodifiable(
        await _repository.fetchHistory(riderId: riderId, query: query),
      );
      _historyState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      _historyState = RiderAnalyticsLoadState.error;
      _historyError = 'Delivery history could not be loaded.';
    }
    notifyListeners();
  }

  Future<void> loadRatings({required String riderId}) async {
    _ratingsState = RiderAnalyticsLoadState.loading;
    _ratingsError = null;
    notifyListeners();
    try {
      _ratings = await _repository.fetchRatings(riderId: riderId);
      _ratingsState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      _ratingsState = RiderAnalyticsLoadState.error;
      _ratingsError = 'Ratings could not be loaded.';
    }
    notifyListeners();
  }
}

RiderAnalyticsRepository _defaultAnalyticsRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderAnalyticsRepository();
  }
  return InMemoryRiderAnalyticsRepository();
}
