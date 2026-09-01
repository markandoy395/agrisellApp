import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_view_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_discovery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_content.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_sheet.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

part 'rider_map_screen_sync.dart';
part 'rider_map_screen_view_state.dart';
part 'rider_map_road_access.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({
    required this.profile,
    required this.deliveryController,
    required this.isActive,
    required this.onOpenList,
    this.locationController,
    this.routeController,
    this.availabilityController,
    this.mapDiscoveryRepository,
    this.roadAccessService,
    super.key,
  });

  final RiderProfile? profile;
  final RiderDeliveryController deliveryController;
  final bool isActive;
  final VoidCallback onOpenList;
  final RiderLocationController? locationController;
  final RiderRouteController? routeController;
  final RiderAvailabilityController? availabilityController;
  final RiderMapDiscoveryRepository? mapDiscoveryRepository;
  final RiderRoadAccessService? roadAccessService;

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  late final RiderLocationController _locationController;
  late final RiderRouteController _routeController;
  late final MapController _mapController;
  late final RiderMapViewCache _viewCache;
  late final RiderMapDiscoveryRepository _mapDiscoveryRepository;
  late final RiderRoadAccessService _roadAccessService;
  RiderDeliverySearch? _lastNearbySearch;
  RiderMapView? _restoredView;
  RiderMapView? _pendingView;
  Timer? _viewSaveDebounce;
  Timer? _roadAccessDebounce;
  var _mapReady = false;
  var _viewRestoreCompleted = false;
  var _filter = RiderMapFilter.all;
  var _mapZoom = 15.0;
  var _navigationActive = false;
  var _followRider = true;
  var _nearbyFarms = const <RiderNearbyFarm>[];
  var _farmSearchGeneration = 0;
  var _farmSearchLoading = false;
  String? _farmDiscoveryError;
  var _roadAccessGeneration = 0;
  String? _lastRoadAccessFingerprint;
  DateTime? _lastRoadAccessAttempt;
  RiderRoadAccessSource? _selectedRoadAccessSource;
  var _roadAccessConnections = const <RiderRoadAccessConnection>[];

  void _replaceRoadAccessConnections(
    List<RiderRoadAccessConnection> connections,
  ) {
    if (!mounted) return;
    setState(() => _roadAccessConnections = List.unmodifiable(connections));
  }

  void _selectRoadAccessSource(RiderRoadAccessSource? source) {
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    setState(() {
      _selectedRoadAccessSource = source;
      _roadAccessConnections = const [];
    });
    if (source != null) _scheduleRoadAccessSync();
  }

  void _clearRoadAccessSelection([String? expectedId]) {
    final selected = _selectedRoadAccessSource;
    if (selected == null || (expectedId != null && selected.id != expectedId)) {
      return;
    }
    _selectRoadAccessSource(null);
  }

  void _changeMapFilter(RiderMapFilter value) {
    if (_filter == value) return;
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    setState(() {
      _filter = value;
      _selectedRoadAccessSource = null;
      _roadAccessConnections = const [];
    });
  }

  @override
  void initState() {
    super.initState();
    _locationController =
        widget.locationController ?? RiderLocationController();
    final defaultRoutingService = OsrmRiderRoutingService();
    _routeController =
        widget.routeController ??
        RiderRouteController(service: defaultRoutingService);
    _roadAccessService =
        widget.roadAccessService ??
        (AgrisellSupabase.isInitialized
            ? defaultRoutingService
            : const DisabledRiderRoadAccessService());
    _mapController = MapController();
    _viewCache = RiderMapViewCache();
    _mapDiscoveryRepository =
        widget.mapDiscoveryRepository ??
        (AgrisellSupabase.isInitialized
            ? SupabaseRiderMapDiscoveryRepository(AgrisellSupabase.client)
            : const InMemoryRiderMapDiscoveryRepository());
    _locationController.addListener(_syncNearbySearch);
    _locationController.addListener(_syncNavigation);
    widget.deliveryController.addListener(_syncNavigation);
    widget.availabilityController?.addListener(_syncConnectivity);
    _syncConnectivity();
    unawaited(_routeController.restore().then((_) => _syncNavigation()));
    unawaited(_restoreMapView());
    if (widget.isActive) {
      _startTracking();
      _syncNearbySearch();
    }
  }

  @override
  void didUpdateWidget(covariant RiderMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncNavigation();
      if (widget.isActive) _syncNearbySearch();
    }
  }

  @override
  void dispose() {
    _locationController.removeListener(_syncNearbySearch);
    _locationController.removeListener(_syncNavigation);
    widget.deliveryController.removeListener(_syncNavigation);
    widget.availabilityController?.removeListener(_syncConnectivity);
    _viewSaveDebounce?.cancel();
    _roadAccessDebounce?.cancel();
    final pendingView = _pendingView;
    if (pendingView != null) unawaited(_viewCache.save(pendingView));
    if (widget.locationController == null) _locationController.dispose();
    if (widget.routeController == null) _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      _locationController,
      widget.deliveryController,
      _routeController,
    ]),
    builder: (context, _) => RiderMapContent(
      controller: _locationController,
      mapController: _mapController,
      requests: widget.deliveryController.requests,
      farms: _nearbyFarms,
      roadAccessConnections: _roadAccessConnections,
      farmDiscoveryError: _farmDiscoveryError,
      farmsLoading: _farmSearchLoading,
      routeController: _routeController,
      riderId: widget.profile?.id,
      filter: _filter,
      mapZoom: _mapZoom,
      discoveryRadiusKm:
          widget.profile?.serviceRadiusKm ??
          RiderDeliverySearch.defaultRadiusKm,
      navigationActive: _navigationActive,
      onFilterChanged: _changeMapFilter,
      onMarkerTap: (request, kind) => unawaited(_openMarker(request, kind)),
      onFarmTap: (farm) => unawaited(_openFarm(farm)),
      onNavigateActive: (request) => unawaited(_startNavigation(request)),
      onExitNavigation: _exitNavigation,
      onRecenter: _recenter,
      onRefresh: () => unawaited(_refreshMapDiscovery()),
      onOpenList: widget.onOpenList,
      onMapReady: _onMapReady,
      onPositionChanged: _onPositionChanged,
    ),
  );

  Future<void> _openMarker(
    DeliveryRequest request,
    RiderMapMarkerKind kind,
  ) async {
    final location = _locationController.location;
    final riderId = widget.profile?.id;
    final active = riderId == null
        ? null
        : widget.deliveryController.requests
              .where(
                (item) => item.isAssignedTo(riderId) && !item.stage.isTerminal,
              )
              .firstOrNull;
    final blocked =
        riderId != null && active != null && !request.isAssignedTo(riderId);
    final destination =
        kind == RiderMapMarkerKind.assignedDelivery &&
            request.stage.isDeliveryLeg
        ? request.deliveryLocation
        : request.pickupLocation;
    final roadAccessSource = _roadAccessSourceForRequest(request, kind);
    _selectRoadAccessSource(roadAccessSource);
    final shouldNavigate = await showRiderMapMarkerSheet(
      context,
      request: request,
      kind: kind,
      distanceKm: location != null && destination.hasCoordinates
          ? RiderDeliverySearch(
              latitude: location.latitude,
              longitude: location.longitude,
            ).distanceTo(
              latitude: destination.latitude!,
              longitude: destination.longitude!,
            )
          : null,
      travelMinutes:
          kind == RiderMapMarkerKind.assignedDelivery &&
              request.stage.isDeliveryLeg
          ? null
          : widget.deliveryController.pickupTravelMinutesFor(request),
      navigationBlockedByActiveDelivery: blocked,
    );
    if (!mounted) return;
    if (!shouldNavigate) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    if (riderId == null) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your rider profile is still loading. Try again.'),
        ),
      );
      return;
    }

    // Navigation does not accept a job. Refresh first so stale or revoked
    // opportunities cannot be routed from an old marker.
    await widget.deliveryController.refreshRequests();
    if (!mounted) return;
    if (!request.isAssignedTo(riderId) &&
        widget.deliveryController.loadState != RiderRequestLoadState.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This opportunity could not be revalidated. Check your connection '
            'and try again.',
          ),
        ),
      );
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    final refreshed = widget.deliveryController.requests
        .where((item) => item.id == request.id)
        .firstOrNull;
    if (refreshed == null ||
        (!refreshed.isAssignedTo(riderId) &&
            !refreshed.isAvailableTo(riderId))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This delivery is no longer available to you.'),
        ),
      );
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    await _startNavigation(refreshed);
  }

  Future<void> _startNavigation(DeliveryRequest request) async {
    final location = _locationController.location;
    if (location == null) return;
    final source = _roadAccessSourceForRequest(
      request,
      RiderMapMarkerKind.assignedDelivery,
    );
    if (_selectedRoadAccessSource?.id != source?.id) {
      _selectRoadAccessSource(source);
    }
    setState(() {
      _navigationActive = true;
      _followRider = true;
    });
    await _routeController.selectRequest(
      requestId: request.id,
      location: location,
      requests: widget.deliveryController.routeOrderedRequests,
    );
    _scheduleRoadAccessSync();
    _fitActiveRoute();
  }

  void _fitActiveRoute() {
    if (!mounted) return;
    final route = _routeController.activeRoute;
    if (_mapReady &&
        route != null &&
        RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      final coordinates = route.points
          .where(
            (point) => RiderMapCameraPolicy.isCoordinateValid(
              point.latitude,
              point.longitude,
            ),
          )
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);
      final padding = RiderMapCameraPolicy.routeFitPadding(
        _mapController.camera.nonRotatedSize,
      );
      if (coordinates.length < 2 || padding == null) return;
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: coordinates,
          padding: padding,
          maxZoom: 16,
        ),
      );
    }
  }

  Future<void> _openFarm(RiderNearbyFarm farm) async {
    final riderId = widget.profile?.id;
    final hasActiveDelivery =
        riderId != null &&
        widget.deliveryController.requests.any(
          (request) =>
              request.isAssignedTo(riderId) && !request.stage.isTerminal,
        );
    final roadAccessSource = _roadAccessSourceForFarm(farm);
    _selectRoadAccessSource(roadAccessSource);
    final shouldNavigate = await showRiderMapFarmSheet(
      context,
      farm: farm,
      navigationBlockedByActiveDelivery: hasActiveDelivery,
    );
    if (!mounted) return;
    if (!shouldNavigate) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    final search = _lastNearbySearch;
    if (search == null) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nearby farm information is still loading.'),
        ),
      );
      return;
    }
    try {
      final refreshed = await _mapDiscoveryRepository.fetchNearbyFarms(search);
      if (!mounted) return;
      final current = refreshed.where((item) => item.id == farm.id).firstOrNull;
      if (current == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This farm is no longer available on the map.'),
          ),
        );
        _clearRoadAccessSelection(roadAccessSource?.id);
        return;
      }
      setState(() => _nearbyFarms = refreshed);
      await _startFarmNavigation(current);
    } on RiderMapDiscoveryException catch (error) {
      if (!mounted) return;
      _clearRoadAccessSelection(roadAccessSource?.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _startFarmNavigation(RiderNearbyFarm farm) async {
    final location = _locationController.location;
    if (location == null) return;
    final source = _roadAccessSourceForFarm(farm);
    final selected = _selectedRoadAccessSource;
    if (selected?.id != source?.id ||
        selected?.point.latitude != source?.point.latitude ||
        selected?.point.longitude != source?.point.longitude) {
      _selectRoadAccessSource(source);
    }
    setState(() {
      _navigationActive = true;
      _followRider = true;
    });
    await _routeController.selectMapDestination(
      destinationId: farm.id,
      destinationLabel: farm.name,
      destination: DeliveryRoutePoint(
        latitude: farm.latitude,
        longitude: farm.longitude,
      ),
      location: location,
      requests: widget.deliveryController.routeOrderedRequests,
    );
    _scheduleRoadAccessSync();
    _fitActiveRoute();
  }

  Future<void> _loadNearbyFarms(RiderDeliverySearch search) async {
    final generation = ++_farmSearchGeneration;
    setState(() {
      _farmSearchLoading = true;
      _farmDiscoveryError = null;
    });
    try {
      final farms = await _mapDiscoveryRepository.fetchNearbyFarms(search);
      if (!mounted || generation != _farmSearchGeneration) return;
      setState(() {
        _nearbyFarms = farms;
        _farmSearchLoading = false;
      });
      _scheduleRoadAccessSync();
    } on RiderMapDiscoveryException catch (error) {
      if (!mounted || generation != _farmSearchGeneration) return;
      setState(() {
        _nearbyFarms = const [];
        _farmSearchLoading = false;
        _farmDiscoveryError = error.message;
      });
    } catch (_) {
      if (!mounted || generation != _farmSearchGeneration) return;
      setState(() {
        _nearbyFarms = const [];
        _farmSearchLoading = false;
        _farmDiscoveryError = 'Nearby farmers could not be loaded.';
      });
    }
  }

  void _exitNavigation() {
    _routeController.clear();
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    setState(() {
      _navigationActive = false;
      _followRider = true;
      _selectedRoadAccessSource = null;
      _roadAccessConnections = const [];
    });
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    _recenter();
  }

  void _recenter() {
    final location = _locationController.location;
    if (!_mapReady ||
        location == null ||
        !RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      return;
    }
    _followRider = true;
    final point = _routeController.displayPoint(location);
    if (!RiderMapCameraPolicy.isCoordinateValid(
      point.latitude,
      point.longitude,
    )) {
      return;
    }
    _mapController.move(
      LatLng(point.latitude, point.longitude),
      RiderMapCameraPolicy.safeZoom(
        _mapController.camera.zoom,
        minimum: 15,
        maximum: 18,
      ),
    );
  }

  void _updateMapZoom(double zoom) => setState(() => _mapZoom = zoom);
}
