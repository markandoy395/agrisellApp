import 'package:flutter/material.dart';

import '../styles/delivery_tracking_sheet_styles.dart';

class DeliveryTrackingHeader extends StatelessWidget {
  const DeliveryTrackingHeader({
    required this.orderId,
    required this.onClose,
    super.key,
  });

  final String orderId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DeliveryTrackingSheetStyles.headerPadding,
      child: Column(
        children: [
          Center(
            child: Container(
              width: DeliveryTrackingSheetStyles.handleWidth,
              height: DeliveryTrackingSheetStyles.handleHeight,
              decoration: DeliveryTrackingSheetStyles.handleDecoration,
            ),
          ),
          const SizedBox(height: DeliveryTrackingSheetStyles.handleBottomGap),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: DeliveryTrackingSheetStyles.headerOrderId,
                    ),
                    const SizedBox(height: DeliveryTrackingSheetStyles.headerTextGap),
                    const Text(
                      'Live GPS & Route Tracking',
                      style: DeliveryTrackingSheetStyles.headerTitle,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: DeliveryTrackingSheetStyles.closeIconSize,
                ),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
