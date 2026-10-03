import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_action_buttons.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_preview_card.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_sheet_header.dart';

/// Opens the modal bottom sheet displaying the waybill preview and print actions.
Future<void> showDeliveryWaybillSheet(
  BuildContext context,
  DeliveryWaybill waybill,
) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryWaybillSheet(waybill: waybill),
    );

/// Modal bottom sheet widget presenting the package delivery waybill slip.
class DeliveryWaybillSheet extends StatelessWidget {
  const DeliveryWaybillSheet({
    required this.waybill,
    super.key,
  });

  final DeliveryWaybill waybill;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * DeliveryWaybillStyles.sheetMaxHeightFactor,
      ),
      decoration: DeliveryWaybillStyles.sheetDecoration,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WaybillSheetHeader(),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('waybill-sheet-scroll'),
                padding: DeliveryWaybillStyles.scrollPadding,
                child: WaybillPreviewCard(waybill: waybill),
              ),
            ),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            WaybillActionButtons(waybill: waybill),
          ],
        ),
      ),
    );
  }
}
