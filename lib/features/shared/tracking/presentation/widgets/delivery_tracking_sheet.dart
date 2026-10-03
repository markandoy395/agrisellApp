import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/presentation/controllers/delivery_tracking_controller.dart';
import '../styles/delivery_tracking_sheet_styles.dart';
import 'delivery_live_map.dart';
import 'delivery_tracking_checkpoints.dart';
import 'delivery_tracking_header.dart';
import 'delivery_tracking_rider_card.dart';
import 'delivery_tracking_status_view.dart';

Future<void> showDeliveryTrackingSheet(
  BuildContext context, {
  required PlacedOrder order,
  DeliveryTrackingController? controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DeliveryTrackingSheet(
      order: order,
      controller: controller,
    ),
  );
}

class DeliveryTrackingSheet extends StatefulWidget {
  const DeliveryTrackingSheet({
    required this.order,
    this.controller,
    super.key,
  });

  final PlacedOrder order;
  final DeliveryTrackingController? controller;

  @override
  State<DeliveryTrackingSheet> createState() => _DeliveryTrackingSheetState();
}

class _DeliveryTrackingSheetState extends State<DeliveryTrackingSheet> {
  late final DeliveryTrackingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = DeliveryTrackingController(order: widget.order);
      _ownsController = true;
    }
    _controller.start();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    } else {
      _controller.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height *
        DeliveryTrackingSheetStyles.sheetMaxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: DeliveryTrackingSheetStyles.sheetDecoration,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final snapshot = _controller.snapshot;
          final isLoading = _controller.isLoading && snapshot == null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DeliveryTrackingHeader(
                orderId: widget.order.id,
                onClose: () => Navigator.of(context).pop(),
              ),
              DeliveryTrackingSheetStyles.headerDivider,
              Expanded(
                child: isLoading
                    ? const DeliveryTrackingLoadingView()
                    : snapshot == null
                        ? DeliveryTrackingErrorView(
                            errorMessage: _controller.errorMessage,
                          )
                        : SingleChildScrollView(
                            padding: DeliveryTrackingSheetStyles.contentPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DeliveryLiveMap(
                                  snapshot: snapshot,
                                  height: DeliveryTrackingSheetStyles.mapHeight,
                                  followRider: _controller.followRider,
                                  onToggleFollowRider: _controller.setFollowRider,
                                  onRefresh: _controller.refresh,
                                  isRefreshing: _controller.isRefreshing,
                                ),
                                if (snapshot.riderName != null) ...[
                                  const SizedBox(
                                    height: DeliveryTrackingSheetStyles.sectionGap,
                                  ),
                                  DeliveryTrackingRiderCard(
                                    riderName: snapshot.riderName!,
                                    riderVehicle: snapshot.riderVehicle,
                                    riderPhone: snapshot.riderPhone,
                                  ),
                                ],
                                const SizedBox(
                                  height: DeliveryTrackingSheetStyles.riderSectionGap,
                                ),
                                DeliveryTrackingCheckpointsList(
                                  checkpoints: snapshot.checkpoints,
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
