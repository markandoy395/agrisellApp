import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../styles/delivery_tracking_sheet_styles.dart';

class DeliveryTrackingRiderCard extends StatelessWidget {
  const DeliveryTrackingRiderCard({
    required this.riderName,
    this.riderVehicle,
    this.riderPhone,
    super.key,
  });

  final String riderName;
  final String? riderVehicle;
  final String? riderPhone;

  void _callRider(String? phone) {
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$clean');
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = riderPhone != null && riderPhone!.isNotEmpty;

    return Container(
      padding: DeliveryTrackingSheetStyles.riderCardPadding,
      decoration: DeliveryTrackingSheetStyles.riderCardDecoration,
      child: Row(
        children: [
          Container(
            width: DeliveryTrackingSheetStyles.riderAvatarSize,
            height: DeliveryTrackingSheetStyles.riderAvatarSize,
            decoration: DeliveryTrackingSheetStyles.riderAvatarDecoration,
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: Colors.white,
              size: DeliveryTrackingSheetStyles.riderAvatarIconSize,
            ),
          ),
          const SizedBox(width: DeliveryTrackingSheetStyles.riderInfoGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riderName,
                  style: DeliveryTrackingSheetStyles.riderName,
                ),
                if (riderVehicle != null) ...[
                  const SizedBox(height: DeliveryTrackingSheetStyles.riderVehicleTopGap),
                  Text(
                    riderVehicle!,
                    style: DeliveryTrackingSheetStyles.riderVehicle,
                  ),
                ],
              ],
            ),
          ),
          if (hasPhone)
            IconButton.filled(
              onPressed: () => _callRider(riderPhone),
              style: DeliveryTrackingSheetStyles.callRiderButtonStyle,
              icon: const Icon(
                Icons.phone_rounded,
                size: DeliveryTrackingSheetStyles.callRiderIconSize,
              ),
              tooltip: 'Call Rider',
            ),
        ],
      ),
    );
  }
}
