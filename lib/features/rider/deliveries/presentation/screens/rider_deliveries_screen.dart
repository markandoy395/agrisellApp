import '../../domain/delivery_stage.dart';
import '../widgets/rider_deliveries_header.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_tabs.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_history_list.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_list.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_offline_sync_banner.dart';

class RiderDeliveriesScreen extends StatelessWidget {
  const RiderDeliveriesScreen({
    required this.profile,
    required this.deliveryController,
    required this.riderId,
    this.locationController,
    this.onRetryLocation,
    this.onOpenLocationSettings,
    this.onOpenAppSettings,
    this.onOpenProfile,
    this.onOpenConversation,
    this.onOpenMap,
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    super.key,
  });

  final RiderProfile? profile;
  final RiderDeliveryController deliveryController;
  final String? riderId;
  final RiderLocationController? locationController;
  final VoidCallback? onRetryLocation;
  final VoidCallback? onOpenLocationSettings;
  final VoidCallback? onOpenAppSettings;
  final VoidCallback? onOpenProfile;
  final Future<bool> Function(String deliveryId)? onOpenConversation;
  final VoidCallback? onOpenMap;
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Material(
        color: AgrisellColors.homeBackground,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: deliveryController,
              builder: (context, _) => RiderDeliveriesHeader(
                onOpenNotifications: onOpenNotifications,
                unreadNotifications: unreadNotifications,
                requestCount: deliveryController.requests
                    .where((item) => item.stage == DeliveryStage.readyForPickup)
                    .length,
                activeCount: deliveryController.requests
                    .where(
                      (item) =>
                          item.stage != DeliveryStage.readyForPickup &&
                          !item.stage.isTerminal,
                    )
                    .length,
              ),
            ),
            AnimatedBuilder(
              animation: deliveryController,
              builder: (context, _) =>
                  RiderOfflineSyncBanner(controller: deliveryController),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: deliveryController,
                builder: (context, _) => TabBarView(
                  children: [
                    RiderRequestList(
                      controller: deliveryController,
                      riderId: riderId,
                      locationController: locationController,
                      onRetryLocation: onRetryLocation,
                      onOpenLocationSettings: onOpenLocationSettings,
                      onOpenAppSettings: onOpenAppSettings,
                      onOpenProfile: onOpenProfile,
                      onOpenConversation: onOpenConversation,
                    ),
                    RiderActiveDeliveryList(
                      controller: deliveryController,
                      riderId: riderId,
                      locationController: locationController,
                      onOpenConversation: onOpenConversation,
                      onOpenMap: onOpenMap,
                      capacityKg: profile?.capacityKg,
                    ),
                    RiderHistoryList(controller: deliveryController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
