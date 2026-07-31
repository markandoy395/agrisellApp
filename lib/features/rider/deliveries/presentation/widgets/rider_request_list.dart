import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_list_states.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_state_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_toolbar.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderRequestList extends StatelessWidget {
  const RiderRequestList({
    required this.controller,
    required this.riderId,
    this.onRetryLocation,
    this.onOpenLocationSettings,
    this.onOpenAppSettings,
    this.onOpenProfile,
    super.key,
  });

  final RiderDeliveryController controller;
  final String? riderId;
  final VoidCallback? onRetryLocation;
  final VoidCallback? onOpenLocationSettings;
  final VoidCallback? onOpenAppSettings;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final access = controller.requestAccessState;
    if (!access.canPreviewRequests) {
      return centerRiderRequestContent(_accessCard(access));
    }
    final requests = controller.requests
        .where((item) => item.stage == DeliveryStage.readyForPickup)
        .toList();
    if (controller.loadState == RiderRequestLoadState.loading &&
        requests.isEmpty) {
      return centerRiderRequestContent(
        const RiderLoadingStateCard(
          title: 'Loading nearby requests',
          message: 'Checking current eligibility, distance, and deadlines.',
        ),
      );
    }
    if (controller.loadState == RiderRequestLoadState.error &&
        requests.isEmpty) {
      return centerRiderRequestContent(
        RiderErrorStateCard(
          title: 'Requests unavailable',
          message: controller.errorMessage ?? 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () => unawaited(controller.refreshRequests()),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refreshRequests,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 280) {
            unawaited(controller.loadMoreRequests());
          }
          return false;
        },
        child: ListView.separated(
          key: const PageStorageKey<String>('rider-request-list'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
          itemCount: _itemCount(requests.length, access),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              _item(context, index, access, requests),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    RiderRequestAccessState access,
    List<DeliveryRequest> requests,
  ) {
    if (index == 0) return RiderRequestToolbar(controller: controller);
    final afterAccess = access == RiderRequestAccessState.eligible ? 1 : 2;
    if (index == 1 && access != RiderRequestAccessState.eligible) {
      return _accessCard(access);
    }
    if (index == afterAccess && requests.isNotEmpty) {
      return riderRequestDataNotice(controller);
    }
    final requestStart = afterAccess + (requests.isEmpty ? 0 : 1);
    if (requests.isEmpty && index == requestStart) {
      return riderRequestEmptyState(controller);
    }
    final requestIndex = index - requestStart;
    if (requestIndex >= requests.length) {
      return const Center(child: CircularProgressIndicator());
    }
    return _requestCard(context, requests[requestIndex]);
  }

  Widget _requestCard(BuildContext context, DeliveryRequest request) =>
      RiderDeliveryRequestCard(
        request: request,
        pickupDistanceKm: controller.pickupDistanceKmFor(request),
        pickupTravelMinutes: controller.pickupTravelMinutesFor(request),
        usesRegisteredLocationEstimate:
            controller.usesRegisteredLocationEstimate,
        isPickupInsideRegisteredServiceArea: controller
            .isPickupInsideRegisteredServiceArea(request),
        canAccept: riderId != null && controller.canAcceptRequest(request.id),
        isAccepting: controller.isAcceptingRequest(request.id),
        onAccept: riderId == null
            ? null
            : () => controller.accept(requestId: request.id, riderId: riderId!),
        onAccepted: (_) => DefaultTabController.of(context).animateTo(1),
        onHide: riderId == null
            ? null
            : () =>
                  controller.decline(requestId: request.id, riderId: riderId!),
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
      );

  int _itemCount(int requestCount, RiderRequestAccessState access) {
    final accessCount = access == RiderRequestAccessState.eligible ? 0 : 1;
    final noticeCount = requestCount == 0 ? 0 : 1;
    final items = requestCount == 0 ? 1 : requestCount;
    return 1 +
        accessCount +
        noticeCount +
        items +
        (controller.isLoadingMore ? 1 : 0);
  }

  RiderRequestAccessCard _accessCard(RiderRequestAccessState state) =>
      RiderRequestAccessCard(
        state: state,
        onRetryLocation: onRetryLocation,
        onOpenLocationSettings: onOpenLocationSettings,
        onOpenAppSettings: onOpenAppSettings,
        onOpenProfile: onOpenProfile,
      );
}
