import 'package:flutter/material.dart';
import '../styles/rider_profile_design_styles.dart';

class RiderProfileEditHeader extends StatelessWidget {
  const RiderProfileEditHeader({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              'Edit rider profile',
              style: RiderProfileDesignStyles.heading,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Use your official Philippine address. We will capture your exact GPS location when you save.',
        style: RiderProfileDesignStyles.caption,
      ),
    ],
  );
}
