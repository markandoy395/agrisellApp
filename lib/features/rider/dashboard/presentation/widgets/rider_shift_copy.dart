import 'package:flutter/material.dart';

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
        const Text(
          'Work status',
          style: RiderAvailabilityCardStyles.workStatusTitleStyle,
        ),
        const SizedBox(height: 5),
        Text(
          RiderAvailabilityCardStyles.statusSummary(
            availability: availability,
            gpsStatus: gpsStatus,
            internetStatus: internetStatus,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: RiderAvailabilityCardStyles.workStatusSubtitleStyle,
        ),
      ],
    );
  }
}
