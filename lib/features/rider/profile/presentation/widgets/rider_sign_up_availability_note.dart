import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';

class RiderSignUpAvailabilityNote extends StatelessWidget {
  const RiderSignUpAvailabilityNote({required this.state, super.key});

  final RiderFieldAvailability state;

  @override
  Widget build(BuildContext context) => switch (state) {
    RiderFieldAvailability.idle => const SizedBox.shrink(),
    RiderFieldAvailability.checking => const Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 6),
          Text('Checking availability...', style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
    RiderFieldAvailability.available => const Padding(
      padding: EdgeInsets.only(top: 5),
      child: Text(
        'Available',
        style: TextStyle(color: AgrisellColors.statusGreenText, fontSize: 12),
      ),
    ),
    RiderFieldAvailability.unavailable => const Padding(
      padding: EdgeInsets.only(top: 5),
      child: Text(
        'Already registered',
        style: TextStyle(color: AgrisellColors.statusRedText, fontSize: 12),
      ),
    ),
  };
}
