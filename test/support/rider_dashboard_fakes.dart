import 'dart:async';

import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_cache.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

class FakeRiderDashboardRepository implements RiderDashboardRepository {
  FakeRiderDashboardRepository({
    RiderDashboardData? data,
    this.shouldFail = false,
    this.gate,
  }) : data = data ?? backendDashboardData();

  RiderDashboardData data;
  bool shouldFail;
  Completer<void>? gate;
  int fetchCalls = 0;
  final List<String> requestedRiders = [];

  @override
  Future<RiderDashboardData> fetchDashboard({required String riderId}) async {
    fetchCalls++;
    requestedRiders.add(riderId);
    await gate?.future;
    if (shouldFail) throw StateError('server failure');
    return data;
  }
}

class FakeRiderDashboardCache implements RiderDashboardCache {
  RiderDashboardData? data;
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<RiderDashboardData?> load(String riderId) async {
    loadCalls++;
    return data;
  }

  @override
  Future<void> save(String riderId, RiderDashboardData value) async {
    saveCalls++;
    data = value;
  }
}

RiderDashboardData backendDashboardData({
  RiderDashboardMetrics metrics = const RiderDashboardMetrics(),
}) => RiderDashboardData(
  metrics: metrics,
  fetchedAt: DateTime.now(),
  dataOrigin: RiderDataOrigin.backend,
);
