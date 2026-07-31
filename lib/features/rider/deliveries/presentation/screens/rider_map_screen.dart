import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_view_cache.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_content.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';

part 'rider_map_screen_sync.dart';
part 'rider_map_screen_view_state.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({
    required this.profile,
    required this.deliveryController,
    required this.isActive,
    required this.onOpenList,
    this.locationController,
    this.routeController,
    this.availabilityController,
    super.key,
  });

  final RiderProfile? profile;
  final RiderDeliveryController deliveryController;
  final bool isActive;
  final VoidCallback onOpenList;
  final RiderLocationController? locationController;
  final RiderRouteController? routeController;
  final RiderAvailabilityController? availabilityController;

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  late final RiderLocationController _locationController;
  late final RiderRouteController _routeController;
  late final MapController _mapController;
  late final RiderMapViewCache _viewCache;
  RiderDeliverySearch? _lastNearbySearch;
  RiderMapView? _restoredView;
  RiderMapView? _pendingView;
  Timer? _viewSaveDebounce;
  var _mapReady = false;
  var _viewRestoreCompleted = false;

  @override
  void initState() {
    super.initState();
    _locationController =
        widget.locationController ?? RiderLocationController();
    _routeController = widget.routeController ?? RiderRouteController();
    _mapController = MapController();
    _viewCache = RiderMapViewCache();
    _locationController.addListener(_syncNearbySearch);
    _locationController.addListener(_syncNavigation);
    widget.deliveryController.addListener(_syncNavigation);
    widget.availabilityController?.addListener(_syncConnectivity);
    _syncConnectivity();
    unawaited(_routeController.restore().then((_) => _syncNavigation()));
    unawaited(_restoreMapView());
    if (widget.isActive) _startTracking();
  }

  @override
  void didUpdateWidget(covariant RiderMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _syncNavigation();
    } else if (oldWidget.isActive && !widget.isActive) {
      _syncNavigation();
    }
  }

  @override
  void dispose() {
    _locationController.removeListener(_syncNearbySearch);
    _locationController.removeListener(_syncNavigation);
    widget.deliveryController.removeListener(_syncNavigation);
    widget.availabilityController?.removeListener(_syncConnectivity);
    _viewSaveDebounce?.cancel();
    final pendingView = _pendingView;
    if (pendingView != null) unawaited(_viewCache.save(pendingView));
    if (widget.locationController == null) _locationController.dispose();
    if (widget.routeController == null) _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          RiderPageHeader(
            title: 'Map & routes',
            subtitle: widget.profile?.gpsLabel ?? 'Live device location',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'List view',
                  onPressed: widget.onOpenList,
                  icon: const Icon(Icons.view_list_rounded),
                  color: AgrisellColors.surface,
                ),
                IconButton(
                  tooltip: 'Refresh location',
                  onPressed: _locationController.refresh,
                  icon: const Icon(Icons.my_location_rounded),
                  color: AgrisellColors.surface,
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _locationController,
                widget.deliveryController,
                _routeController,
              ]),
              builder: (context, _) => RiderMapContent(
                controller: _locationController,
                mapController: _mapController,
                requests: widget.deliveryController.requests,
                routeController: _routeController,
                riderId: widget.profile?.id,
                onMapReady: _onMapReady,
                onPositionChanged: _onPositionChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
