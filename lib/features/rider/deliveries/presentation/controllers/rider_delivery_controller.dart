import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_offline_remote.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_sync_engine.dart';
import 'package:agresell_app/features/rider/deliveries/data/offline_delivery_command_codec.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_action_result.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_ordering.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_state_snapshot.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_active_delivery_snapshot.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_status_helpers.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_problem.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_offline_sync.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_request_state.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_active_delivery_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_optimizer.dart';

export 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_request_state.dart';

part 'rider_delivery_controller_actions.dart';
part 'rider_delivery_controller_persistence.dart';
part 'rider_delivery_controller_requests.dart';
part 'rider_delivery_controller_request_matching.dart';
part 'rider_delivery_controller_status.dart';
part 'rider_delivery_controller_status_actions.dart';
part 'rider_delivery_controller_pickup.dart';
part 'rider_delivery_controller_loading.dart';
part 'rider_delivery_controller_completion.dart';
part 'rider_delivery_controller_waiting.dart';
part 'rider_delivery_controller_offline.dart';
part 'rider_delivery_controller_recovery.dart';
part 'rider_delivery_controller_problems.dart';
part 'rider_delivery_controller_batch.dart';
part 'rider_delivery_controller_state.dart';
part 'rider_delivery_controller_failure.dart';

class RiderDeliveryController extends ChangeNotifier {
  factory RiderDeliveryController({
    RiderDeliveryRepository? repository,
    RiderDeliveryStateStore? stateStore,
    RiderOfflineActionQueue? offlineQueue,
    RiderOfflineSyncEngine? syncEngine,
    Duration acceptanceTimeout = const Duration(seconds: 15),
  }) {
    final resolvedRepository = repository ?? _defaultDeliveryRepository();
    final resolvedQueue = offlineQueue ?? RiderOfflineActionQueue();
    final resolvedEngine =
        syncEngine ??
        RiderOfflineSyncEngine(
          queue: resolvedQueue,
          remote: RiderDeliveryOfflineRemote(resolvedRepository),
        );
    return RiderDeliveryController._(
      resolvedRepository,
      stateStore,
      resolvedQueue,
      resolvedEngine,
      offlineQueue == null,
      syncEngine == null,
      acceptanceTimeout,
    );
  }

  RiderDeliveryController._(
    this._repository,
    this._stateStore,
    this._offlineQueue,
    this._syncEngine,
    this._ownsOfflineQueue,
    this._ownsSyncEngine,
    this._acceptanceTimeout,
  ) {
    _offlineQueue.addListener(_offlineQueueChanged);
    _syncEngine.addListener(_offlineSyncChanged);
  }

  final RiderDeliveryRepository _repository;
  final RiderDeliveryStateStore? _stateStore;
  final RiderOfflineActionQueue _offlineQueue;
  final RiderOfflineSyncEngine _syncEngine;
  final bool _ownsOfflineQueue;
  final bool _ownsSyncEngine;
  final Duration _acceptanceTimeout;
  var _loadState = RiderRequestLoadState.loading;
  var _status = const RiderDeliveryStatus(
    verificationStatus: RiderVerificationStatus.pending,
    availability: RiderAvailability.offline,
  );
  List<DeliveryRequest> _requests = const [];
  String? _errorMessage;
  String? _riderId;
  RiderDeliverySearch? _search;
  double? _requestAccuracyMeters;
  int _pendingOfflineActionCount = 0;
  DateTime? _lastSynchronizationTime;
  RiderProfile? _profile;
  RiderRequestAccessState _requestAccess =
      RiderRequestAccessState.locationUnavailable;
  RiderRequestSort _requestSort = RiderRequestSort.recommended;
  RiderRequestFilters _requestFilters = const RiderRequestFilters();
  String _searchText = '';
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  Timer? _searchDebounce;
  int _requestGeneration = 0;
  StreamSubscription<void>? _requestUpdates;
  String? _watchedRiderId;
  Timer? _realtimeDebounce;
  final Map<String, Future<DeliveryAcceptanceOutcome>> _acceptanceOperations =
      {};
  final Map<String, String> _acceptanceKeys = {};
  final Random _secureRandom = Random.secure();
  final RiderActiveDeliveryState _activeDeliveries = RiderActiveDeliveryState();
  final Map<String, Future<DeliveryActionResult>> _statusOperations = {};
  final Map<String, Future<DeliveryActionResult>> _pickupOperations = {};
  final Map<String, Future<DeliveryActionResult>> _completionOperations = {};
  List<DeliveryCompletionRecord> _completionHistory = const [];
  DeliveryStatusLocation? _currentRiderLocation;
  bool _isBackendReachable = true;
  bool _offlineQueueInitialized = false;
  bool _isRestoring = false;
  bool _isDisposed = false;
  Map<String, Object?> _recoveryData = const {};
  final Map<String, RiderDeliveryProblemReport> _deliveryProblemReports = {};

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    _realtimeDebounce?.cancel();
    unawaited(_requestUpdates?.cancel());
    _offlineQueue.removeListener(_offlineQueueChanged);
    _syncEngine.removeListener(_offlineSyncChanged);
    if (_ownsSyncEngine) _syncEngine.dispose();
    if (_ownsOfflineQueue) _offlineQueue.dispose();
    super.dispose();
  }
}

RiderDeliveryRepository _defaultDeliveryRepository() =>
    AgrisellSupabase.isInitialized
    ? SupabaseRiderDeliveryRepository(
        SupabaseDeliveryDataSource(AgrisellSupabase.client),
      )
    : InMemoryRiderDeliveryRepository();
