import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';

class RiderAvailabilitySwitch extends StatelessWidget {
  const RiderAvailabilitySwitch({
    required this.isOnline,
    required this.isBusy,
    required this.onChanged,
    super.key,
  });

  final bool isOnline;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isOnline ? 'Go offline' : 'Go online',
      button: true,
      child: Switch.adaptive(
        value: isOnline,
        activeThumbColor: AgrisellColors.surface,
        activeTrackColor: RiderAvailabilityCardStyles.activeThumbColor,
        inactiveThumbColor: AgrisellColors.surface,
        inactiveTrackColor: AgrisellColors.deliveryGray,
        onChanged: isBusy ? null : onChanged,
      ),
    );
  }
}
