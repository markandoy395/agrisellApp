part of 'rider_dashboard_screen.dart';

extension _RiderDashboardContent on _RiderDashboardScreenState {
  List<Widget> _content() {
    final delivery = widget.deliveryController;
    final riderId = widget.riderId ?? '';
    final active = delivery.routeOrderedRequests
        .where(
          (request) =>
              request.isAssignedTo(riderId) && !request.stage.isTerminal,
        )
        .toList(growable: false);
    final nearby = delivery.requests
        .where((request) => request.stage == DeliveryStage.readyForPickup)
        .toList();
    return [
      RiderDashboardStateBanner(
        dashboard: widget.dashboardController,
        availability: widget.availabilityController,
        onRetry: () => unawaited(_refresh()),
        onEnableGps: () => unawaited(
          widget.availabilityController.locationController
              .openLocationSettings(),
        ),
        onRequestPermission: () => unawaited(
          widget.availabilityController.locationController.refresh(
            requestPermission: true,
          ),
        ),
        onOpenAppSettings: () => unawaited(
          widget.availabilityController.locationController.openAppSettings(),
        ),
        onRefreshLocation: () => unawaited(
          widget.availabilityController.locationController.refresh(),
        ),
      ),
      const SizedBox(height: 14),
      if (_showEarningsSnapshot) ...[
        _RiderEarningsSnapshot(
          amount: widget.dashboardController.metrics.todayEstimatedEarnings,
          pendingAmount: widget.dashboardController.metrics.pendingEarnings,
          online: widget.availabilityController.availability.isOnline,
          onTap: widget.onOpenEarnings,
        ),
      ],
      const SizedBox(height: 12),
      if (active.length <= 1)
        RiderActiveDeliverySummary(
          delivery: active.firstOrNull,
          onContinue: widget.onOpenDeliveries,
          onOpenMap: widget.onOpenMap,
        )
      else ...[
        RiderActiveDeliverySummary(
          delivery: active.first,
          onContinue: widget.onOpenDeliveries,
          onOpenMap: widget.onOpenMap,
        ),
        const SizedBox(height: 12),
        RiderActiveBatchSummary(
          deliveries: active,
          plan: delivery.batchPlan,
          capacityKg: widget.profile?.capacityKg,
          onSelectDelivery: (deliveryId) {
            delivery.selectActiveDelivery(deliveryId);
            widget.onOpenDeliveries();
          },
        ),
      ],
      const SizedBox(height: 12),
      RiderNearbyRequestSummary(
        requests: nearby,
        isTemporary: delivery.usesTemporaryData,
        onOpenList: widget.onOpenDeliveries,
      ),
      const SizedBox(height: 12),
      RiderDashboardMetricsGrid(
        metrics: widget.dashboardController.metrics,
        activeDeliveryCount: active.length,
        todaySummaryAvailable: !_sectionUnavailable('Today metrics'),
        earningsAvailable: !_sectionUnavailable('Earnings'),
        communicationAvailable: !_sectionUnavailable('Communication counts'),
        onOpenEarnings: widget.onOpenEarnings,
        onOpenMessages: widget.onOpenMessages,
        onOpenNotifications: widget.onOpenNotifications,
      ),
      const SizedBox(height: 12),
      RiderEarningGuide(onOpenEarnings: widget.onOpenEarnings),
      const SizedBox(height: 12),
      RiderPerformanceSummary(
        profile: widget.profile,
        metrics: widget.dashboardController.metrics,
      ),
      if (widget.profile case final profile?
          when !profile.hasCargoCapacity) ...[
        const SizedBox(height: 14),
        RiderCapacitySetupBanner(onSetCapacity: _openCapacitySetup),
      ],
      const SizedBox(height: 14),
      _RiderSafetySupportCard(onTap: widget.onSafetySupport),
    ];
  }

  bool _sectionUnavailable(String name) {
    return widget.dashboardController.sectionUnavailable(name);
  }

  bool get _showEarningsSnapshot => !_sectionUnavailable('Earnings');
}
