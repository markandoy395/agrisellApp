import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import 'package:agresell_app/features/shared/tracking/presentation/controllers/delivery_tracking_controller.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_live_map.dart';

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

  void _callRider(String? phone) {
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$clean');
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final snapshot = _controller.snapshot;
          final isLoading = _controller.isLoading && snapshot == null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Handle & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AgrisellColors.borderLine,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.id,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AgrisellColors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Live GPS & Route Tracking',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AgrisellColors.brandBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AgrisellColors.borderLine),

              // Content Area
              Expanded(
                child: isLoading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AgrisellColors.authGreen,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Connecting to Live Rider GPS…',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AgrisellColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : snapshot == null
                        ? Center(
                            child: Text(
                              _controller.errorMessage ?? 'Tracking unavailable.',
                              style: const TextStyle(
                                color: AgrisellColors.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Live Map
                                DeliveryLiveMap(
                                  snapshot: snapshot,
                                  height: 320,
                                  followRider: _controller.followRider,
                                  onToggleFollowRider: _controller.setFollowRider,
                                  onRefresh: _controller.refresh,
                                  isRefreshing: _controller.isRefreshing,
                                ),

                                const SizedBox(height: 16),

                                // Rider Info Card
                                if (snapshot.riderName != null)
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AgrisellColors.forestSoft,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AgrisellColors.authGreen.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AgrisellColors.authGreen,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AgrisellColors.authGreen.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.two_wheeler_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.riderName!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: AgrisellColors.brandBlack,
                                                ),
                                              ),
                                              if (snapshot.riderVehicle != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  snapshot.riderVehicle!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AgrisellColors.mutedText,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (snapshot.riderPhone != null &&
                                            snapshot.riderPhone!.isNotEmpty)
                                          IconButton.filled(
                                            onPressed: () => _callRider(snapshot.riderPhone),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AgrisellColors.authGreen,
                                              foregroundColor: Colors.white,
                                            ),
                                            icon: const Icon(Icons.phone_rounded, size: 20),
                                            tooltip: 'Call Rider',
                                          ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 18),

                                // Checkpoint Tracking Timeline
                                const Text(
                                  'Delivery Checkpoints',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AgrisellColors.brandBlack,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                for (var i = 0; i < snapshot.checkpoints.length; i++)
                                  _CheckpointItem(
                                    checkpoint: snapshot.checkpoints[i],
                                    isLast: i == snapshot.checkpoints.length - 1,
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

class _CheckpointItem extends StatelessWidget {
  const _CheckpointItem({
    required this.checkpoint,
    required this.isLast,
  });

  final DeliveryTrackingCheckpoint checkpoint;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = checkpoint.isCompleted;
    final isActive = checkpoint.isActive;

    final Color dotColor = isDone
        ? AgrisellColors.authGreen
        : (isActive ? const Color(0xFFD97706) : AgrisellColors.deliveryGray);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator with vertical connector line
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AgrisellColors.authGreen
                      : (isActive ? const Color(0xFFD97706) : Colors.white),
                  border: Border.all(
                    color: dotColor,
                    width: 2,
                  ),
                  boxShadow: [
                    if (isActive || isDone)
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : (isActive
                        ? const Center(
                            child: SizedBox(
                              width: 8,
                              height: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AgrisellColors.authGreen : AgrisellColors.borderLine,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Checkpoint Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          checkpoint.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive || isDone ? FontWeight.w800 : FontWeight.w600,
                            color: isActive || isDone
                                ? AgrisellColors.brandBlack
                                : AgrisellColors.mutedText,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'In Progress',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (checkpoint.notes != null && checkpoint.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      checkpoint.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AgrisellColors.mutedText,
                      ),
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
