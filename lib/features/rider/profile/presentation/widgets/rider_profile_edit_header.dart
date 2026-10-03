import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_styles.dart';

class RiderProfileEditHeader extends StatelessWidget {
  const RiderProfileEditHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: RiderProfileEditStyles.dragHandleWidth,
        height: RiderProfileEditStyles.dragHandleHeight,
        decoration: RiderProfileEditStyles.dragHandleDecoration,
      ),
      RiderProfileEditStyles.spacingLarge,
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Edit rider profile',
          style: RiderProfileEditStyles.titleStyle,
        ),
      ),
      RiderProfileEditStyles.spacingSmall,
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Use your official Philippine address. We will capture your exact GPS location when you save.',
          style: RiderProfileEditStyles.subtitleStyle,
        ),
      ),
    ],
  );
}
