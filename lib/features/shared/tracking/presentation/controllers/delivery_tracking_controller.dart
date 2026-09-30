import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/data/delivery_tracking_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

class DeliveryTrackingController extends ChangeNotifier {
  DeliveryTrackingController({
    required this.order,
    DeliveryTrackingService? service,
    Duration refreshInterval = const Duration(seconds: 15),
  })  : _service = service ?? DeliveryTrackingService(),
        _refreshInterval = refreshInterval;

  final PlacedOrder order;
  final DeliveryTrackingService _service;
  final Duration _refreshInterval;

  DeliveryTrackingSnapshot? _snapshot;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _followRider = false;
  Timer? _pollingTimer;
  bool _disposed = false;

  DeliveryTrackingSnapshot? get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get followRider => _followRider;

  bool get hasCoordinates =>
      _snapshot != null &&
      (_snapshot!.hasRiderCoordinates ||
          _snapshot!.destination != null ||
          _snapshot!.pickup != null);

  void start() {
    if (_pollingTimer != null) return;
    unawaited(_fetch(initial: true));
    _pollingTimer = Timer.periodic(_refreshInterval, (_) {
      unawaited(_fetch(initial: false));
    });
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void setFollowRider(bool value) {
    if (_followRider == value) return;
    _followRider = value;
    notifyListeners();
  }

  Future<void> refresh() => _fetch(initial: false, isManual: true);

  Future<void> _fetch({bool initial = false, bool isManual = false}) async {
    if (_disposed) return;
    if (initial) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else if (isManual) {
      _isRefreshing = true;
      notifyListeners();
    }

    try {
      final result = await _service.fetchTracking(order);
      if (_disposed) return;
      _snapshot = result;
      _errorMessage = null;
    } catch (e) {
      if (_disposed) return;
      if (initial) {
        _errorMessage = 'Unable to load delivery tracking.';
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    super.dispose();
  }
}
