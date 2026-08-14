import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ColoredBox(
        color: AgrisellColors.homeBackground,
        child: Column(
          children: [
            const RiderPageHeader(
              title: 'Deliveries',
              subtitle: 'Requests, active trips, and delivery history',
            ),
            const TabBar(
              labelColor: AgrisellColors.authGreen,
              unselectedLabelColor: AgrisellColors.mutedText,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              tabs: [
                Tab(text: 'Requests'),
                Tab(text: 'Active'),
                Tab(text: 'History'),
              ],
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
