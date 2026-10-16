import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/rider_route_controller.dart';
import '../controllers/rider_location_controller.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_map_design_styles.dart';

class RiderMapRouteLoading extends StatelessWidget {
  const RiderMapRouteLoading({
    required this.controller,
    required this.locationController,
    required this.requests,
    super.key,
  });
  final RiderRouteController controller;
  final RiderLocationController locationController;
  final List<DeliveryRequest> requests;

  @override
  Widget build(BuildContext context) {
    final loading = controller.state == RiderRouteState.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loading ? 'Finding route...' : 'Route unavailable',
          style: RiderMapDesignStyles.title,
        ),
        if (loading) const LinearProgressIndicator(),
        if (!loading) ...[
          Text(
            controller.errorMessage ??
                'Choose a destination to calculate a road route.',
            style: RiderMapDesignStyles.caption,
          ),
          TextButton.icon(
            onPressed:
                !controller.canRefresh || locationController.location == null
                ? null
                : () => unawaited(
                    controller.refreshRoute(
                      location: locationController.location!,
                      requests: requests,
                    ),
                  ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry route'),
          ),
        ],
      ],
    );
  }
}
