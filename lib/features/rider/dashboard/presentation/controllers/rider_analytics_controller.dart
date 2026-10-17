import 'package:flutter/foundation.dart';
import 'package:agresell_app/core/utils/async_request_scope.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';
import '../../domain/rider_wallet.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';

part 'rider_analytics_wallet.dart';

enum RiderAnalyticsLoadState { idle, loading, ready, error }

class RiderAnalyticsController extends ChangeNotifier {
  RiderAnalyticsController({RiderAnalyticsRepository? repository})
    : _repository = repository ?? _defaultAnalyticsRepository();

  final RiderAnalyticsRepository _repository;
  final _scope = AsyncRequestScope();
  final _operations = AsyncOperationGate();
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  var _earningsState = RiderAnalyticsLoadState.idle;
  var _historyState = RiderAnalyticsLoadState.idle;
  var _ratingsState = RiderAnalyticsLoadState.idle;
  RiderEarningsData _earnings = const RiderEarningsData.empty();
  List<RiderDeliveryHistoryEntry> _history = const [];
  RiderRatingsData _ratings = const RiderRatingsData.empty();
  List<RiderWithdrawalMethod> _withdrawalMethods = const [];
  List<RiderWithdrawalRequest> _withdrawalRequests = const [];
  String? _earningsError;
  String? _historyError;
  String? _ratingsError;
  RiderWallet? wallet;
  String? walletError;

  RiderAnalyticsLoadState get earningsState => _earningsState;
  RiderAnalyticsLoadState get historyState => _historyState;
  RiderAnalyticsLoadState get ratingsState => _ratingsState;
  RiderEarningsData get earnings => _earnings;
  List<RiderDeliveryHistoryEntry> get history => List.unmodifiable(_history);
  RiderRatingsData get ratings => _ratings;
  List<RiderWithdrawalMethod> get withdrawalMethods =>
      List.unmodifiable(_withdrawalMethods);
  List<RiderWithdrawalRequest> get withdrawalRequests =>
      List.unmodifiable(_withdrawalRequests);
  String? get earningsError => _earningsError;
  String? get historyError => _historyError;
  String? get ratingsError => _ratingsError;

  Future<void> loadEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  }) async {
    final ticket = _scope.begin('earnings');
    _earningsState = RiderAnalyticsLoadState.loading;
    _earningsError = null;
    notifyListeners();
    try {
      final value = await _repository.fetchEarnings(
        riderId: riderId,
        dateRange: dateRange,
      );
      if (!ticket.isCurrent) return;
      _earnings = value;
      _earningsState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      if (!ticket.isCurrent) return;
      _earningsState = RiderAnalyticsLoadState.error;
      _earningsError = 'Earnings could not be loaded.';
    }
    notifyListeners();
  }

  Future<void> loadHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  }) async {
    final ticket = _scope.begin('history');
    _historyState = RiderAnalyticsLoadState.loading;
    _historyError = null;
    notifyListeners();
    try {
      final values = List<RiderDeliveryHistoryEntry>.unmodifiable(
        await _repository.fetchHistory(riderId: riderId, query: query),
      );
      if (!ticket.isCurrent) return;
      _history = values;
      _historyState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      if (!ticket.isCurrent) return;
      _historyState = RiderAnalyticsLoadState.error;
      _historyError = 'Delivery history could not be loaded.';
    }
    notifyListeners();
  }

  Future<void> loadRatings({required String riderId}) async {
    final ticket = _scope.begin('ratings');
    _ratingsState = RiderAnalyticsLoadState.loading;
    _ratingsError = null;
    notifyListeners();
    try {
      final value = await _repository.fetchRatings(riderId: riderId);
      if (!ticket.isCurrent) return;
      _ratings = value;
      _ratingsState = RiderAnalyticsLoadState.ready;
    } catch (_) {
      if (!ticket.isCurrent) return;
      _ratingsState = RiderAnalyticsLoadState.error;
      _ratingsError = 'Ratings could not be loaded.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _scope.dispose();
    super.dispose();
  }
}

RiderAnalyticsRepository _defaultAnalyticsRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderAnalyticsRepository();
  }
  return InMemoryRiderAnalyticsRepository();
}
