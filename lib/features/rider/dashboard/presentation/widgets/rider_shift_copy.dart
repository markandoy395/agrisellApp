import 'package:flutter/material.dart';
import '../styles/rider_home_design_styles.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';

class RiderShiftCopy extends StatelessWidget {
  const RiderShiftCopy({
    required this.availability,
    required this.gpsStatus,
    required this.internetStatus,
    super.key,
  });

  final RiderAvailability availability;
  final RiderGpsStatus gpsStatus;
  final RiderInternetStatus internetStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Work status', style: RiderHomeDesignStyles.caption),
        const SizedBox(height: 5),
        Text(
          RiderAvailabilityCardStyles.availabilityLabel(availability),
          style: RiderHomeDesignStyles.title,
        ),
        const SizedBox(height: 3),
        Text(
          availability.canReceiveRequests
              ? 'Available for deliveries'
              : availability.isHandlingDelivery
              ? 'Continue your current delivery'
              : availability == RiderAvailability.offline
              ? 'Turn on to start receiving deliveries'
              : 'Delivery availability is paused',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: RiderAvailabilityCardStyles.workStatusSubtitleStyle,
        ),
      ],
    );
  }
}
