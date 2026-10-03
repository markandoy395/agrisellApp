import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_confirmation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_confirmation_actions.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_confirmation_content.dart';

Future<bool> showFarmerRiderConfirmationDialog(
  BuildContext context, {
  required FarmerRiderCandidate rider,
  required FarmerRiderDeliveryDetails delivery,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: FarmerRiderConfirmationStyles.barrierColor,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: FarmerRiderConfirmationStyles.dialogShape,
        insetPadding: FarmerRiderConfirmationStyles.dialogInsetPadding,
        constraints: FarmerRiderConfirmationStyles.dialogConstraints,
        scrollable: true,
        titlePadding: FarmerRiderConfirmationStyles.dialogTitlePadding,
        contentPadding: FarmerRiderConfirmationStyles.dialogContentPadding,
        actionsPadding: FarmerRiderConfirmationStyles.dialogActionsPadding,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: FarmerRiderConfirmationStyles.headerIconBoxSize,
                    height: FarmerRiderConfirmationStyles.headerIconBoxSize,
                    decoration:
                        FarmerRiderConfirmationStyles.headerIconBoxDecoration,
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: FarmerRiderConfirmationStyles.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confirm rider request',
                    style: FarmerRiderConfirmationStyles.titleStyle,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Review your delivery details before sending.',
                    style: FarmerRiderConfirmationStyles.subtitleStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close confirmation',
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(
                Icons.close_rounded,
                color: FarmerRiderConfirmationStyles.muted,
                size: 22,
              ),
            ),
          ],
        ),
        content: FarmerRiderConfirmationContent(
          rider: rider,
          delivery: delivery,
        ),
        actions: const [
          FarmerRiderConfirmationActions(),
        ],
      ),
    ) ??
    false;
