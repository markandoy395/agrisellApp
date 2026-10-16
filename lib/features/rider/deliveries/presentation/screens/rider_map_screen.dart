import 'dart:async';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:flutter/material.dart';
import '../../domain/rider_map_visibility.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'rider_delivery_details_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_view_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_discovery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/utils/rider_map_road_access_resolver.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_content.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_sheet.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

part 'rider_map_screen_sync.dart';
part 'rider_map_screen_content.dart';
part 'rider_map_screen_view_state.dart';
part 'rider_map_road_access.dart';
part 'rider_map_marker_actions.dart';
part 'rider_map_farm_discovery.dart';
part 'rider_map_navigation.dart';
part 'rider_map_road_access_selection.dart';

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
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    this.onOpenConversation,
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
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;
  final Future<bool> Function(String deliveryId)? onOpenConversation;

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
  var _visibility = const RiderMapVisibility();
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
  Widget build(BuildContext context) => _buildMapScreen(context);

  void _showMapMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
  }

  void _updateMapState(VoidCallback update) => setState(update);

  void _updateMapZoom(double zoom) => setState(() => _mapZoom = zoom);
}
