import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_offline_state_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderVerificationPanel extends StatelessWidget {
  const RiderVerificationPanel({required this.profile, super.key});

  final RiderProfile? profile;

  @override
  Widget build(BuildContext context) {
    final status = profile?.verificationStatus;
    final isVerified = status == RiderVerificationStatus.verified;
    final isRejected =
        status == RiderVerificationStatus.rejected ||
        status == RiderVerificationStatus.suspended;
    final background = isVerified
        ? AgrisellColors.statusGreenBackground
        : isRejected
        ? AgrisellColors.statusRedBackground
        : AgrisellColors.statusOrangeBackground;
    final foreground = isVerified
        ? AgrisellColors.statusGreenText
        : isRejected
        ? AgrisellColors.statusRedText
        : AgrisellColors.statusOrangeText;
    return RiderSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderVerificationPill(
            label: status?.label ?? 'Profile required',
            backgroundColor: background,
            foregroundColor: foreground,
            icon: isVerified ? Icons.verified_rounded : Icons.pending_outlined,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'You can only accept deliveries after your rider account is verified.',
              style: TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RiderNearbyRequests extends StatelessWidget {
  const RiderNearbyRequests({
    required this.controller,
    required this.riderId,
    super.key,
  });

  final RiderDeliveryController controller;
  final String? riderId;

  @override
  Widget build(BuildContext context) {
    final requests = controller.requests
        .where((request) => request.stage == DeliveryStage.readyForPickup)
        .toList();
    return switch (controller.loadState) {
      RiderRequestLoadState.loading => const RiderLoadingStateCard(
        title: 'Loading pickup requests',
        message: 'Checking nearby ready-to-pickup orders.',
      ),
      RiderRequestLoadState.error => RiderErrorStateCard(
        title: 'Pickup requests unavailable',
        message: controller.errorMessage ?? 'Please try again.',
        retryLabel: 'Try again',
        onRetry: riderId == null
            ? null
            : () => controller.load(riderId: riderId!),
      ),
      RiderRequestLoadState.offline => const RiderOfflineStateCard(
        title: 'You are offline',
        message: 'Reconnect to receive nearby pickup requests.',
      ),
      RiderRequestLoadState.ready when requests.isEmpty =>
        const RiderEmptyStateCard(
          title: 'No nearby pickups yet',
          message:
              'New ready-to-pickup orders will appear here when delivery data is available.',
          icon: Icons.local_shipping_outlined,
        ),
      RiderRequestLoadState.ready => Column(
        children: [
          for (final request in requests) ...[
            RiderDeliveryRequestCard(
              request: request,
              pickupDistanceKm: controller.pickupDistanceKmFor(request),
              pickupTravelMinutes: controller.pickupTravelMinutesFor(request),
              usesRegisteredLocationEstimate:
                  controller.usesRegisteredLocationEstimate,
              isPickupInsideRegisteredServiceArea: controller
                  .isPickupInsideRegisteredServiceArea(request),
              canAccept:
                  riderId != null && controller.canAcceptRequest(request.id),
              isAccepting: controller.isAcceptingRequest(request.id),
              onAccept: riderId == null
                  ? null
                  : () => controller.accept(
                      requestId: request.id,
                      riderId: riderId!,
                    ),
              onAccepted: (accepted) => Navigator.of(context).push(
                agrisellPageRoute<void>(
                  builder: (_) => RiderDeliveryDetailsScreen(
                    request: accepted,
                    controller: controller,
                    riderId: riderId!,
                  ),
                ),
              ),
              onViewDetails: riderId == null
                  ? null
                  : () => Navigator.of(context).push(
                      agrisellPageRoute<void>(
                        builder: (_) => RiderDeliveryDetailsScreen(
                          request: request,
                          controller: controller,
                          riderId: riderId!,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    };
  }
}
