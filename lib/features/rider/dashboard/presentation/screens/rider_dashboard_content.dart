part of 'rider_dashboard_screen.dart';

extension _RiderDashboardContent on _RiderDashboardScreenState {
  List<Widget> _content() {
    final delivery = widget.deliveryController;
    final riderId = widget.riderId ?? '';
    final active = delivery.requests
        .where(
          (request) =>
              request.isAssignedTo(riderId) && !request.stage.isTerminal,
        )
        .firstOrNull;
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
      const SizedBox(height: 12),
      RiderAvailabilityCard(controller: widget.availabilityController),
      const SizedBox(height: 16),
      const RiderSectionTitle(title: 'Current delivery'),
      const SizedBox(height: 8),
      RiderActiveDeliverySummary(
        delivery: active,
        onContinue: widget.onOpenDeliveries,
        onOpenMap: widget.onOpenMap,
      ),
      const SizedBox(height: 16),
      const RiderSectionTitle(title: 'Nearby requests'),
      const SizedBox(height: 8),
      RiderNearbyRequestSummary(
        requests: nearby,
        isTemporary: delivery.usesTemporaryData,
        onOpenList: widget.onOpenDeliveries,
      ),
      const SizedBox(height: 16),
      const RiderSectionTitle(title: 'Today at a glance'),
      const SizedBox(height: 8),
      RiderDashboardMetricsGrid(
        metrics: widget.dashboardController.metrics,
        activeDeliveryCount: active == null ? 0 : 1,
        todaySummaryAvailable: !_sectionUnavailable('Today metrics'),
        earningsAvailable: !_sectionUnavailable('Earnings'),
        communicationAvailable: !_sectionUnavailable('Communication counts'),
        onOpenEarnings: widget.onOpenEarnings,
        onOpenMessages: widget.onOpenMessages,
        onOpenNotifications: widget.onOpenNotifications,
      ),
      const SizedBox(height: 16),
      RiderPerformanceSummary(
        profile: widget.profile,
        metrics: widget.dashboardController.metrics,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: widget.onSafetySupport,
        icon: const Icon(Icons.shield_outlined, size: 18),
        label: const Text('Safety and support'),
      ),
    ];
  }

  bool _sectionUnavailable(String name) {
    return widget.dashboardController.sectionUnavailable(name);
  }
}
