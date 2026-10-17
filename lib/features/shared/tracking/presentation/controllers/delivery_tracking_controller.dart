import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';
import 'package:agresell_app/core/utils/async_request_scope.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/data/delivery_tracking_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

class DeliveryTrackingController extends ChangeNotifier
    with WidgetsBindingObserver {
  DeliveryTrackingController({
    required this.order,
    DeliveryTrackingService? service,
    Duration refreshInterval = const Duration(seconds: 15),
  }) : _service = service ?? DeliveryTrackingService(),
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
  bool _started = false;
  final _requests = AsyncOperationGate();
  final _scope = AsyncRequestScope();

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
    if (_disposed || _started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _resume();
  }

  void _resume() {
    if (_disposed || !_started || _pollingTimer != null) return;
    unawaited(_fetch(initial: true));
    if (_refreshInterval <= Duration.zero) return;
    _pollingTimer = Timer.periodic(_refreshInterval, (_) {
      unawaited(_fetch(initial: false));
    });
  }

  void stop() {
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _scope.invalidate('tracking');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resume();
    } else {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  void setFollowRider(bool value) {
    if (_followRider == value) return;
    _followRider = value;
    notifyListeners();
  }

  Future<void> refresh() => _fetch(initial: false, isManual: true);

  Future<void> _fetch({bool initial = false, bool isManual = false}) =>
      _requests.run(
        'tracking',
        () => _fetchOnce(initial: initial, isManual: isManual),
      );

  Future<void> _fetchOnce({bool initial = false, bool isManual = false}) async {
    if (_disposed) return;
    final ticket = _scope.begin('tracking');
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
      if (!ticket.isCurrent) return;
      _snapshot = result;
      _errorMessage = null;
    } catch (e) {
      if (!ticket.isCurrent) return;
      if (initial) {
        _errorMessage = 'Unable to load delivery tracking.';
      }
    } finally {
      if (ticket.isActive) {
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    stop();
    _disposed = true;
    _scope.dispose();
    _pollingTimer?.cancel();
    _pollingTimer = null;
    super.dispose();
  }
}
