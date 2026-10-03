import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/delivery_tracking_sheet_styles.dart';

class DeliveryTrackingLoadingView extends StatelessWidget {
  const DeliveryTrackingLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AgrisellColors.authGreen,
          ),
          SizedBox(height: DeliveryTrackingSheetStyles.loadingIndicatorGap),
          Text(
            'Connecting to Live Rider GPS…',
            style: DeliveryTrackingSheetStyles.loadingText,
          ),
        ],
      ),
    );
  }
}

class DeliveryTrackingErrorView extends StatelessWidget {
  const DeliveryTrackingErrorView({
    this.errorMessage,
    super.key,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMessage ?? 'Tracking unavailable.',
        style: DeliveryTrackingSheetStyles.errorText,
      ),
    );
  }
}
