import 'package:flutter/material.dart';

import '../styles/farmer_farm_edit_styles.dart';

class FarmerFarmEditHeader extends StatelessWidget {
  const FarmerFarmEditHeader({
    required this.isCapturing,
    required this.locationError,
    required this.onRetryGps,
    super.key,
  });

  final bool isCapturing;
  final String? locationError;
  final VoidCallback onRetryGps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Farm', style: FarmerFarmEditStyles.titleStyle),
        FarmerFarmEditStyles.spacingTitleSubtitle,
        const Text(
          'Update the farm used for your product listings.',
          style: FarmerFarmEditStyles.subtitleStyle,
        ),
        FarmerFarmEditStyles.spacingHeaderBottom,
        if (isCapturing) ...[
          const LinearProgressIndicator(),
          FarmerFarmEditStyles.spacingProgressText,
          const Text(
            'Capturing your current farm location...',
            style: FarmerFarmEditStyles.capturingTextStyle,
          ),
          FarmerFarmEditStyles.spacingCapturingBottom,
        ],
        if (locationError != null) ...[
          Text(locationError!, style: FarmerFarmEditStyles.errorTextStyle),
          TextButton.icon(
            onPressed: isCapturing ? null : onRetryGps,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Retry GPS capture'),
          ),
          FarmerFarmEditStyles.spacingErrorBottom,
        ],
      ],
    );
  }
}
