import 'dart:async';
import 'package:agresell_app/core/utils/async_request_scope.dart';

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
  final _scope = AsyncRequestScope();
  bool _disposed = false;
  bool _refreshing = false;

  FarmerRiderAssignmentLoadState get state => _state;
  String? get errorMessage => _errorMessage;

  FarmerRiderRequest? requestFor(String orderId) => _latestByOrder[orderId];

  bool isCancelling(String requestId) => _cancelling.contains(requestId);

  void start() {
    if (_disposed || _subscription != null) return;
    final ticket = _scope.begin('watch');
    _state = FarmerRiderAssignmentLoadState.loading;
    _subscription = repository.watchCurrentRequests().listen(
      (values) {
        if (!ticket.isCurrent) return;
        _scope.invalidate('refresh');
        _replaceAll(values);
      },
      onError: (Object error) {
        if (!ticket.isCurrent) return;
        _state = FarmerRiderAssignmentLoadState.error;
        _errorMessage = _message(error);
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    if (_disposed || _refreshing) return;
    _refreshing = true;
    final ticket = _scope.begin('refresh');
    try {
      final values = await repository.loadCurrentRequests();
      if (ticket.isCurrent) _replaceAll(values);
    } on Object catch (error) {
      if (!ticket.isCurrent) return;
      _state = FarmerRiderAssignmentLoadState.error;
      _errorMessage = _message(error);
      notifyListeners();
    } finally {
      _refreshing = false;
    }
  }

  void apply(FarmerRiderRequest request) {
    if (_disposed) return;
    _scope.invalidate('refresh');
    final current = _latestByOrder[request.orderId];
    if (current == null || !current.requestedAt.isAfter(request.requestedAt)) {
      _latestByOrder[request.orderId] = request;
      _state = FarmerRiderAssignmentLoadState.ready;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<FarmerRiderRequest> cancel(FarmerRiderRequest request) async {
    if (_disposed) throw StateError('This rider request screen is closed.');
    if (_cancelling.contains(request.id)) return request;
    _cancelling.add(request.id);
    final ticket = _scope.begin(('cancel', request.id));
    notifyListeners();
    try {
      final updated = await repository.cancelRequest(request.id);
      if (ticket.isCurrent) apply(updated);
      return updated;
    } finally {
      _cancelling.remove(request.id);
      if (ticket.isCurrent) notifyListeners();
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
    _disposed = true;
    _scope.dispose();
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
