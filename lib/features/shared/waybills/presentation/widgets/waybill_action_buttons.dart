import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_sheet_actions.dart';

/// Bottom action bar providing print, download, and clipboard copy operations.
class WaybillActionButtons extends StatelessWidget {
  const WaybillActionButtons({
    required this.waybill,
    super.key,
  });

  final DeliveryWaybill waybill;

  @override
  Widget build(BuildContext context) => Padding(
    padding: DeliveryWaybillStyles.actionsPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: DeliveryWaybillStyles.primaryActionHeight,
          child: ElevatedButton.icon(
            key: const Key('waybill-print-button'),
            onPressed: () => WaybillSheetActions.printWaybill(context, waybill),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text(
              'Print Waybill',
              style: DeliveryWaybillStyles.primaryButtonText,
            ),
            style: DeliveryWaybillStyles.printButtonStyle,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: DeliveryWaybillStyles.secondaryActionHeight,
                child: OutlinedButton.icon(
                  key: const Key('waybill-download-button'),
                  onPressed: () =>
                      WaybillSheetActions.downloadWaybill(context, waybill),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text(
                    'Save HTML',
                    style: DeliveryWaybillStyles.secondaryButtonText,
                  ),
                  style: DeliveryWaybillStyles.secondaryActionButtonStyle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: DeliveryWaybillStyles.secondaryActionHeight,
                child: OutlinedButton.icon(
                  key: const Key('waybill-copy-button'),
                  onPressed: () =>
                      WaybillSheetActions.copyWaybill(context, waybill),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text(
                    'Copy Text',
                    style: DeliveryWaybillStyles.secondaryButtonText,
                  ),
                  style: DeliveryWaybillStyles.secondaryActionButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
