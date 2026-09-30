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
      RiderAvailabilityCard(controller: widget.availabilityController),
      if (_showEarningsSnapshot) ...[
        const SizedBox(height: 10),
        _RiderEarningsSnapshot(
          amount: widget.dashboardController.metrics.todayEstimatedEarnings,
          pendingAmount: widget.dashboardController.metrics.pendingEarnings,
        ),
      ],
      const SizedBox(height: 18),
      const RiderSectionTitle(title: 'Your next move'),
      const SizedBox(height: 10),
      if (active.length <= 1)
        RiderActiveDeliverySummary(
          delivery: active.firstOrNull,
          onContinue: widget.onOpenDeliveries,
          onOpenMap: widget.onOpenMap,
        )
      else
        RiderActiveBatchSummary(
          deliveries: active,
          plan: delivery.batchPlan,
          capacityKg: widget.profile?.capacityKg,
          onSelectDelivery: (deliveryId) {
            delivery.selectActiveDelivery(deliveryId);
            widget.onOpenDeliveries();
          },
        ),
      const SizedBox(height: 18),
      RiderSectionTitle(
        title: 'Ready for pickup',
        action: TextButton.icon(
          onPressed: widget.onOpenDeliveries,
          icon: const Icon(Icons.list_alt_rounded, size: 17),
          label: const Text('View all'),
        ),
      ),
      const SizedBox(height: 10),
      RiderNearbyRequestSummary(
        requests: nearby,
        isTemporary: delivery.usesTemporaryData,
        onOpenList: widget.onOpenDeliveries,
      ),
      const SizedBox(height: 18),
      const RiderSectionTitle(title: 'Today at a glance'),
      const SizedBox(height: 10),
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
      const SizedBox(height: 18),
      RiderPerformanceSummary(
        profile: widget.profile,
        metrics: widget.dashboardController.metrics,
      ),
      const SizedBox(height: 14),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSafetySupport,
        child: RiderSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AgrisellColors.statusBlueBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AgrisellColors.statusBlueText,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety and support',
                      style: TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Get help, report an issue, or review safety tools.',
                      style: TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AgrisellColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  bool _sectionUnavailable(String name) {
    return widget.dashboardController.sectionUnavailable(name);
  }

  bool get _showEarningsSnapshot =>
      !_sectionUnavailable('Earnings') &&
      widget.dashboardController.metrics.todayEstimatedEarnings > 0;
}

class _RiderEarningsSnapshot extends StatelessWidget {
  const _RiderEarningsSnapshot({required this.amount, this.pendingAmount});

  final double amount;
  final double? pendingAmount;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AgrisellColors.limeSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AgrisellColors.authGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHP ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Estimated earnings today',
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (pendingAmount != null) ...[
                const SizedBox(height: 3),
                Text(
                  'PHP ${pendingAmount!.toStringAsFixed(2)} pending',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
