import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';

enum FarmerRiderAssignmentLoadState { loading, ready, error }

class FarmerRiderAssignmentController extends ChangeNotifier {
  FarmerRiderAssignmentController(this.repository);

  final FarmerRiderSelectionRepository repository;
  final Map<String, FarmerRiderRequest> _latestByOrder = {};
  StreamSubscription<List<FarmerRiderRequest>>? _subscription;
  FarmerRiderAssignmentLoadState _state =
      FarmerRiderAssignmentLoadState.loading;
  String? _errorMessage;
  final Set<String> _cancelling = {};

  FarmerRiderAssignmentLoadState get state => _state;
  String? get errorMessage => _errorMessage;

  FarmerRiderRequest? requestFor(String orderId) => _latestByOrder[orderId];

  bool isCancelling(String requestId) => _cancelling.contains(requestId);

  void start() {
    if (_subscription != null) return;
    _state = FarmerRiderAssignmentLoadState.loading;
    _subscription = repository.watchCurrentRequests().listen(
      _replaceAll,
      onError: (Object error) {
        _state = FarmerRiderAssignmentLoadState.error;
        _errorMessage = _message(error);
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    try {
      _replaceAll(await repository.loadCurrentRequests());
    } on Object catch (error) {
      _state = FarmerRiderAssignmentLoadState.error;
      _errorMessage = _message(error);
      notifyListeners();
    }
  }

  void apply(FarmerRiderRequest request) {
    final current = _latestByOrder[request.orderId];
    if (current == null || !current.requestedAt.isAfter(request.requestedAt)) {
      _latestByOrder[request.orderId] = request;
      _state = FarmerRiderAssignmentLoadState.ready;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<FarmerRiderRequest> cancel(FarmerRiderRequest request) async {
    if (_cancelling.contains(request.id)) return request;
    _cancelling.add(request.id);
    notifyListeners();
    try {
      final updated = await repository.cancelRequest(request.id);
      apply(updated);
      return updated;
    } finally {
      _cancelling.remove(request.id);
      notifyListeners();
    }
  }

  void _replaceAll(List<FarmerRiderRequest> requests) {
    _latestByOrder.clear();
    final ordered = [...requests]
      ..sort((left, right) => right.requestedAt.compareTo(left.requestedAt));
    for (final request in ordered) {
      _latestByOrder.putIfAbsent(request.orderId, () => request);
    }
    _state = FarmerRiderAssignmentLoadState.ready;
    _errorMessage = null;
    notifyListeners();
  }

  String _message(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'Rider request updates are unavailable.' : message;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
