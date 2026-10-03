import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import '../styles/delivery_tracking_sheet_styles.dart';

class DeliveryTrackingCheckpointsList extends StatelessWidget {
  const DeliveryTrackingCheckpointsList({
    required this.checkpoints,
    super.key,
  });

  final List<DeliveryTrackingCheckpoint> checkpoints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Checkpoints',
          style: DeliveryTrackingSheetStyles.checkpointsTitle,
        ),
        const SizedBox(height: DeliveryTrackingSheetStyles.checkpointsTitleGap),
        for (var i = 0; i < checkpoints.length; i++)
          DeliveryTrackingCheckpointItem(
            checkpoint: checkpoints[i],
            isLast: i == checkpoints.length - 1,
          ),
      ],
    );
  }
}

class DeliveryTrackingCheckpointItem extends StatelessWidget {
  const DeliveryTrackingCheckpointItem({
    required this.checkpoint,
    required this.isLast,
    super.key,
  });

  final DeliveryTrackingCheckpoint checkpoint;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = checkpoint.isCompleted;
    final isActive = checkpoint.isActive;
    final dotColor = DeliveryTrackingSheetStyles.checkpointDotColor(
      isDone: isDone,
      isActive: isActive,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator with vertical connector line
          Column(
            children: [
              Container(
                width: DeliveryTrackingSheetStyles.checkpointDotSize,
                height: DeliveryTrackingSheetStyles.checkpointDotSize,
                decoration: DeliveryTrackingSheetStyles.checkpointDotDecoration(
                  isDone: isDone,
                  isActive: isActive,
                  dotColor: dotColor,
                ),
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: DeliveryTrackingSheetStyles.checkpointCheckIconSize,
                        color: Colors.white,
                      )
                    : (isActive
                        ? const Center(
                            child: SizedBox(
                              width: DeliveryTrackingSheetStyles.checkpointInnerDotSize,
                              height: DeliveryTrackingSheetStyles.checkpointInnerDotSize,
                              child: DecoratedBox(
                                decoration:
                                    DeliveryTrackingSheetStyles.checkpointInnerDotDecoration,
                              ),
                            ),
                          )
                        : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: DeliveryTrackingSheetStyles.checkpointConnectorWidth,
                    color: DeliveryTrackingSheetStyles.connectorLineColor(
                      isDone: isDone,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: DeliveryTrackingSheetStyles.checkpointContentGap),
          // Checkpoint Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : DeliveryTrackingSheetStyles.checkpointItemBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          checkpoint.label,
                          overflow: TextOverflow.ellipsis,
                          style: DeliveryTrackingSheetStyles.checkpointLabel(
                            isEmphasized: isActive || isDone,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: DeliveryTrackingSheetStyles.checkpointBadgeGap),
                        Container(
                          padding: DeliveryTrackingSheetStyles.inProgressBadgePadding,
                          decoration: DeliveryTrackingSheetStyles.inProgressBadgeDecoration,
                          child: const Text(
                            'In Progress',
                            style: DeliveryTrackingSheetStyles.inProgressBadgeTextLabel,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (checkpoint.notes != null && checkpoint.notes!.isNotEmpty) ...[
                    const SizedBox(height: DeliveryTrackingSheetStyles.checkpointNotesGap),
                    Text(
                      checkpoint.notes!,
                      style: DeliveryTrackingSheetStyles.checkpointNotes,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
