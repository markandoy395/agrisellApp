import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_active_delivery_summary.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_active_batch_summary.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_availability_card.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_delivery_summary.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_header.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_metrics.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_state_banner.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_performance_summary.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

part 'rider_dashboard_content.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({
    required this.profile,
    required this.deliveryController,
    required this.availabilityController,
    required this.dashboardController,
    required this.riderId,
    required this.onOpenDeliveries,
    required this.onOpenMap,
    required this.onOpenMessages,
    required this.onOpenEarnings,
    required this.onOpenNotifications,
    required this.onSafetySupport,
    super.key,
  });

  final RiderProfile? profile;
  final RiderDeliveryController deliveryController;
  final RiderAvailabilityController availabilityController;
  final RiderDashboardController dashboardController;
  final String? riderId;
  final VoidCallback onOpenDeliveries;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenEarnings;
  final VoidCallback onOpenNotifications;
  final VoidCallback onSafetySupport;

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final riderId = widget.riderId;
    if (riderId != null) {
      unawaited(widget.dashboardController.load(riderId: riderId));
    }
  }

  @override
  void didUpdateWidget(covariant RiderDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riderId != widget.riderId && widget.riderId != null) {
      unawaited(
        widget.dashboardController.load(riderId: widget.riderId!, force: true),
      );
    }
  }

  Future<void> _refresh() async {
    final riderId = widget.riderId;
    await Future.wait([
      widget.dashboardController.refresh(),
      widget.availabilityController.refreshEnvironment(),
      // Active deliveries must refresh even when the Rider cannot receive an
      // additional request (for example while a delivery is in progress).
      if (riderId != null) widget.deliveryController.load(riderId: riderId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.dashboardController;
    final availability = widget.availabilityController;
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([dashboard, availability]),
            builder: (context, _) => RiderDashboardHeader(
              profile: widget.profile,
              workStatus: availability.availability,
              unreadNotifications: dashboard.metrics.unreadNotificationCount,
              onOpenNotifications: widget.onOpenNotifications,
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                dashboard,
                availability,
                availability.locationController,
                widget.deliveryController,
              ]),
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final sidePadding = constraints.maxWidth > 760
                      ? (constraints.maxWidth - 760) / 2 + 18
                      : 16.0;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      scrollCacheExtent: const ScrollCacheExtent.pixels(10000),
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        16,
                        sidePadding,
                        156,
                      ),
                      children: _content(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
