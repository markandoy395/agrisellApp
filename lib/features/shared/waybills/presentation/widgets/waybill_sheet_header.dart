import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart';

/// Top section of the delivery waybill sheet containing drag handle and title.
class WaybillSheetHeader extends StatelessWidget {
  const WaybillSheetHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildHandle(),
      _buildHeader(context),
    ],
  );

  Widget _buildHandle() => Container(
    margin: DeliveryWaybillStyles.handleMargin,
    width: DeliveryWaybillStyles.handleWidth,
    height: DeliveryWaybillStyles.handleHeight,
    decoration: DeliveryWaybillStyles.handleDecoration,
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: DeliveryWaybillStyles.headerPadding,
    child: Row(
      children: [
        const Icon(
          Icons.receipt_long_rounded,
          color: AgrisellColors.authGreen,
          size: 22,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Waybill',
                style: DeliveryWaybillStyles.headerTitle,
              ),
              Text(
                'Printable package receipt & courier slip',
                style: DeliveryWaybillStyles.headerSubtitle,
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('waybill-close-button'),
          icon: const Icon(
            Icons.close_rounded,
            color: AgrisellColors.mutedText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
