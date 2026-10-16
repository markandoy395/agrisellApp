import 'package:flutter/material.dart';

import '../../domain/delivery_waybill.dart';
import '../styles/delivery_waybill_styles.dart';

class WaybillPreviewHeader extends StatelessWidget {
  const WaybillPreviewHeader({required this.waybill, super.key});

  final DeliveryWaybill waybill;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final identifiers = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            waybill.waybillNumber,
            style: DeliveryWaybillStyles.waybillNumber,
          ),
          Text(
            'Order ORD-${waybill.orderId}',
            style: DeliveryWaybillStyles.orderNumber,
          ),
        ],
      );
      final badge = Container(
        padding: DeliveryWaybillStyles.badgePadding,
        decoration: DeliveryWaybillStyles.badgeDecoration(isCod: waybill.isCod),
        child: Text(
          waybill.isCod ? 'CASH ON DELIVERY' : 'PREPAID',
          style: DeliveryWaybillStyles.badgeTextStyle(isCod: waybill.isCod),
        ),
      );
      if (constraints.maxWidth < 400 ||
          MediaQuery.textScalerOf(context).scale(12) > 18) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [identifiers, const SizedBox(height: 8), badge],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: identifiers),
          const SizedBox(width: 12),
          Flexible(child: badge),
        ],
      );
    },
  );
}
