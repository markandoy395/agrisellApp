import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_cache.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_dashboard_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';

class RiderDashboardController extends ChangeNotifier {
  RiderDashboardController({
    RiderDashboardRepository? repository,
    RiderDashboardCache? cache,
    this.staleAfter = const Duration(minutes: 2),
  }) : _repository = repository ?? _defaultDashboardRepository(),
       _cache = cache ?? SharedPreferencesRiderDashboardCache();

  final RiderDashboardRepository _repository;
  final RiderDashboardCache _cache;
  final Duration staleAfter;
  RiderDashboardLoadState _state = RiderDashboardLoadState.initialLoading;
  RiderDashboardData? _data;
  String? _errorMessage;
  String? _riderId;
  Future<void>? _request;
  var _requestGeneration = 0;
  int _localCompletedToday = 0;

  RiderDashboardLoadState get state => _state;
  RiderDashboardData? get data => _data;
  RiderDashboardMetrics get metrics {
    final base = _data?.metrics ?? const RiderDashboardMetrics();
    return base.copyWith(
      todayCompletedDeliveries:
          _localCompletedToday > base.todayCompletedDeliveries
          ? _localCompletedToday
          : base.todayCompletedDeliveries,
    );
  }

  String? get errorMessage => _errorMessage;
  bool get usesTemporaryData => _data?.usesTemporaryData ?? false;
  bool get hasCachedData => _data != null;

  bool sectionUnavailable(String name) =>
      name == 'Today metrics' && _localCompletedToday > 0
      ? false
      : _data?.unavailableSections.contains(name) ?? false;

  void applyLocalCompletedToday(int count) {
    if (count < 0 || count == _localCompletedToday) return;
    _localCompletedToday = count;
    notifyListeners();
  }

  bool get isStale {
    final fetchedAt = _data?.fetchedAt;
    return fetchedAt == null ||
        DateTime.now().difference(fetchedAt) >= staleAfter;
  }

  Future<void> load({required String riderId, bool force = false}) {
    final riderChanged = _riderId != riderId;
    if (riderChanged) {
      _riderId = riderId;
      _requestGeneration++;
    }
    final existing = _request;
    if (existing != null) {
      return riderChanged
          ? existing.whenComplete(() => load(riderId: riderId, force: true))
          : existing;
    }
    if (!force && !isStale) return Future<void>.value();
    final request = _load(riderId);
    _request = request;
    return request.whenComplete(() {
      if (identical(_request, request)) _request = null;
    });
  }

  Future<void> refresh() {
    final riderId = _riderId;
    if (riderId == null) return Future<void>.value();
    return load(riderId: riderId, force: true);
  }

  Future<void> _load(String riderId) async {
    final generation = ++_requestGeneration;
    _state = _data == null
        ? RiderDashboardLoadState.initialLoading
        : RiderDashboardLoadState.refreshing;
    _errorMessage = null;
    notifyListeners();
    final Future<Object> fetch = _repository
        .fetchDashboard(riderId: riderId)
        .then<Object>((data) => data, onError: (Object error) => error);
    if (_data == null) {
      try {
        final cached = await _cache.load(riderId);
        if (generation != _requestGeneration) return;
        if (cached != null) {
          _data = cached;
          _state = RiderDashboardLoadState.refreshing;
          notifyListeners();
        }
      } catch (_) {
        // A cache failure must not prevent a repository refresh.
      }
    }
    try {
      final outcome = await fetch;
      if (outcome is! RiderDashboardData) throw outcome;
      final result = outcome;
      if (generation != _requestGeneration) return;
      _data = result;
      _state = result.isPartial
          ? RiderDashboardLoadState.partialData
          : RiderDashboardLoadState.ready;
      try {
        await _cache.save(riderId, result);
      } catch (_) {
        // Dashboard caching is best-effort and stores non-sensitive metrics.
      }
    } catch (_) {
      if (generation != _requestGeneration) return;
      _errorMessage = _data == null
          ? 'The Rider dashboard could not be loaded.'
          : 'Some dashboard sections could not be refreshed.';
      _state = _data == null
          ? RiderDashboardLoadState.serverError
          : RiderDashboardLoadState.partialData;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _requestGeneration++;
    super.dispose();
  }
}

RiderDashboardRepository _defaultDashboardRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderDashboardRepository();
  }
  return const TemporaryLocalRiderDashboardRepository();
}
