import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_delivery_request_card_content_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_action_result.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_acceptance_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_summary.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_priority.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_hide_dialog.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';

part 'rider_delivery_request_card_content.dart';
part 'rider_delivery_request_card_state.dart';

class RiderDeliveryRequestCard extends StatefulWidget {
  const RiderDeliveryRequestCard({
    required this.request,
    required this.canAccept,
    required this.onAccept,
    this.pickupDistanceKm,
    this.pickupTravelMinutes,
    this.usesRegisteredLocationEstimate = false,
    this.isPickupInsideRegisteredServiceArea = true,
    this.isAccepting = false,
    this.onAccepted,
    this.onViewDetails,
    this.onHide,
    super.key,
  });

  final DeliveryRequest request;
  final bool canAccept;
  final Future<DeliveryAcceptanceOutcome> Function()? onAccept;
  final double? pickupDistanceKm;
  final int? pickupTravelMinutes;
  final bool usesRegisteredLocationEstimate;
  final bool isPickupInsideRegisteredServiceArea;
  final bool isAccepting;
  final ValueChanged<DeliveryRequest>? onAccepted;
  final VoidCallback? onViewDetails;
  final Future<DeliveryActionResult> Function()? onHide;

  @override
  State<RiderDeliveryRequestCard> createState() =>
      _RiderDeliveryRequestCardState();
}
