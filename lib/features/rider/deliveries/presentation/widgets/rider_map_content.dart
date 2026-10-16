import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import '../../domain/rider_map_visibility.dart';
import '../../domain/delivery_status.dart';
import 'rider_map_toolbar.dart';
import 'rider_map_options_sheet.dart';
import 'rider_map_maneuver_banner.dart';
import 'rider_map_discovery_sheet.dart';
import 'rider_map_navigation_sheet.dart';
import 'rider_map_status_control.dart';
import 'rider_map_floating_controls.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_location_fallback.dart';
part 'rider_map_content_layout.dart';

class RiderMapContent extends StatelessWidget {
  const RiderMapContent({
    required this.controller,
    required this.mapController,
    required this.requests,
    required this.farms,
    required this.roadAccessConnections,
    required this.farmDiscoveryError,
    required this.farmsLoading,
    required this.routeController,
    required this.riderId,
    required this.filter,
    required this.mapZoom,
    required this.discoveryRadiusKm,
    required this.navigationActive,
    required this.onFilterChanged,
    required this.onMarkerTap,
    required this.onFarmTap,
    required this.onNavigateActive,
    required this.onExitNavigation,
    required this.onRecenter,
    required this.onRefresh,
    required this.onOpenList,
    required this.onMapReady,
    required this.onPositionChanged,
    this.visibility = const RiderMapVisibility(),
    this.onVisibilityChanged,
    this.online,
    this.onOnlineChanged,
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    this.onOpenDelivery,
    this.onMessage,
    this.statusFor,
    super.key,
  });

  final RiderLocationController controller;
  final MapController mapController;
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final List<RiderRoadAccessConnection> roadAccessConnections;
  final String? farmDiscoveryError;
  final bool farmsLoading;
  final RiderRouteController routeController;
  final String? riderId;
  final RiderMapFilter filter;
  final double mapZoom;
  final double discoveryRadiusKm;
  final bool navigationActive;
  final ValueChanged<RiderMapFilter> onFilterChanged;
  final RiderMapMarkerCallback onMarkerTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;
  final ValueChanged<DeliveryRequest> onNavigateActive;
  final VoidCallback onExitNavigation;
  final VoidCallback onRecenter;
  final VoidCallback onRefresh;
  final VoidCallback onOpenList;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  final RiderMapVisibility visibility;
  final ValueChanged<RiderMapVisibility>? onVisibilityChanged;
  final bool? online;
  final ValueChanged<bool>? onOnlineChanged;
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;
  final ValueChanged<DeliveryRequest>? onOpenDelivery;
  final ValueChanged<DeliveryRequest>? onMessage;
  final DeliveryStatus Function(DeliveryRequest)? statusFor;

  @override
  Widget build(BuildContext context) =>
      Material(color: AgrisellColors.homeBackground, child: _buildMap(context));
}
