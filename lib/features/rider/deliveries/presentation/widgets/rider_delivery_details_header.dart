import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_status.dart';
import '../delivery_status_presentation.dart';
import '../styles/rider_delivery_reference_styles.dart';
export 'rider_detail_navigation_addresses.dart';

class RiderDeliveryDetailsHeader extends StatelessWidget {
  const RiderDeliveryDetailsHeader({
    required this.orderNumber,
    required this.onWaybill,
    this.requestReview = false,
    super.key,
  });
  final String orderNumber;
  final VoidCallback onWaybill;
  final bool requestReview;
  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.2;
    return Container(
      decoration: RiderDeliveryReferenceStyles.header,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 10, 16),
          child: Row(
            children: [
              const BackButton(color: AgrisellColors.surface),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery details',
                      style: RiderDeliveryReferenceStyles.heading,
                    ),
                    const SizedBox(height: 3),
                    if (!compact)
                      Text(
                        requestReview
                            ? 'Order information and request details'
                            : 'Order information and delivery progress',
                        style: RiderDeliveryReferenceStyles.whiteCaption,
                      ),
                    Text(
                      orderNumber,
                      style: RiderDeliveryReferenceStyles.whiteCaption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Print Delivery Waybill',
                child: SizedBox(
                  width: 76,
                  child: TextButton(
                    key: const Key('rider-print-waybill-button'),
                    style: RiderDeliveryReferenceStyles.headerWaybill,
                    onPressed: onWaybill,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.print_outlined,
                          color: AgrisellColors.surface,
                          size: 24,
                        ),
                        Text(
                          'Print\nWaybill',
                          softWrap: false,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: RiderDeliveryReferenceStyles.whiteCaption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiderDeliveryDetailsStatusBanner extends StatelessWidget {
  const RiderDeliveryDetailsStatusBanner({
    required this.status,
    this.requestReview = false,
    super.key,
  });
  final DeliveryStatus status;
  final bool requestReview;
  @override
  Widget build(BuildContext context) {
    final color = requestReview
        ? AgrisellColors.statusOrangeText
        : status.isSpecialResolution
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: RiderDeliveryReferenceStyles.tint(color),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Icon(
              requestReview ? Icons.schedule_rounded : status.icon,
              color: AgrisellColors.surface,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requestReview
                      ? 'New delivery request'
                      : status.isTerminal || status.isSpecialResolution
                      ? status.displayLabel
                      : 'In progress',
                  style: RiderDeliveryReferenceStyles.title,
                ),
                const SizedBox(height: 3),
                Text(
                  requestReview
                      ? 'Review the details and accept if you can deliver.'
                      : status.isTerminal
                      ? 'Review this delivery record.'
                      : 'Continue with the current delivery.',
                  style: RiderDeliveryReferenceStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
