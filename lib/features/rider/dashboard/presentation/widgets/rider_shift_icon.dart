import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';

class RiderShiftIcon extends StatelessWidget {
  const RiderShiftIcon({required this.availability, super.key});

  final RiderAvailability availability;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RiderAvailabilityCardStyles.iconBoxSize,
      height: RiderAvailabilityCardStyles.iconBoxSize,
      alignment: Alignment.center,
      decoration: RiderAvailabilityCardStyles.iconBoxDecoration(availability),
      child: Icon(
        Icons.sensors_rounded,
        color: RiderAvailabilityCardStyles.iconColor(availability),
        size: RiderAvailabilityCardStyles.iconSize,
      ),
    );
  }
}
