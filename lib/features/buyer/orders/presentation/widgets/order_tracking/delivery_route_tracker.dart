part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _DeliveryRouteTracker extends StatelessWidget {
  const _DeliveryRouteTracker({
    required this.status,
    this.order,
  });

  final PlacedOrderStatus status;
  final PlacedOrder? order;

  static const _steps = [
    _RouteStep(label: 'Order Placed', icon: Icons.receipt_long_rounded),
    _RouteStep(label: 'Accepted', icon: Icons.verified_outlined),
    _RouteStep(label: 'Preparing', icon: Icons.inventory_2_outlined),
    _RouteStep(label: 'Ready for Pickup', icon: Icons.storefront_outlined),
    _RouteStep(label: 'Shipping', icon: Icons.route_rounded),
    _RouteStep(label: 'Completed', icon: Icons.task_alt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = switch (status) {
      PlacedOrderStatus.toPay => 0,
      PlacedOrderStatus.toShip => 0,
      PlacedOrderStatus.preparing => 2,
      PlacedOrderStatus.readyForPickup => 3,
      PlacedOrderStatus.shipping => 4,
      PlacedOrderStatus.delivered => 5,
      PlacedOrderStatus.cancelled => 0,
    };
    final routeColor = switch (status) {
      PlacedOrderStatus.toPay => AgrisellColors.statusOrangeText,
      PlacedOrderStatus.cancelled => AgrisellColors.statusRedText,
      _ => AgrisellColors.authGreen,
    };

    final isTrackingAvailable = order != null &&
        (status == PlacedOrderStatus.shipping ||
            status == PlacedOrderStatus.readyForPickup ||
            status == PlacedOrderStatus.delivered);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AgrisellColors.authGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 6-step progress bar
            LayoutBuilder(
              builder: (context, constraints) {
                final stepWidth = constraints.maxWidth / _steps.length;
                final lineLeft = stepWidth / 2;
                final lineWidth = constraints.maxWidth - stepWidth;
                final progress = activeIndex / (_steps.length - 1);

                return SizedBox(
                  height: 42,
                  child: Stack(
                    children: [
                      Positioned(
                        left: lineLeft,
                        top: 16,
                        width: lineWidth,
                        child: const _RouteLine(color: AgrisellColors.deliveryGray),
                      ),
                      Positioned(
                        left: lineLeft,
                        top: 16,
                        width: lineWidth * progress,
                        child: _RouteLine(color: routeColor),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var index = 0; index < _steps.length; index++)
                            Expanded(
                              child: _RouteStop(
                                step: _steps[index],
                                isActive: index <= activeIndex,
                                color: routeColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Live GPS & ETA Window Bar
            if (isTrackingAvailable && order != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AgrisellColors.borderLine),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => showDeliveryTrackingSheet(context, order: order!),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AgrisellColors.authGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status == PlacedOrderStatus.shipping
                                  ? 'Rider en route • Live GPS active'
                                  : (status == PlacedOrderStatus.readyForPickup
                                      ? 'Awaiting pickup • Live Map available'
                                      : 'Delivered • View route summary'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AgrisellColors.brandBlack,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              status == PlacedOrderStatus.shipping
                                  ? 'ETA: ~15 mins (2.4 km) • ~28 km/h'
                                  : 'Tap to inspect live map & checkpoints',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AgrisellColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AgrisellColors.authGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_rounded, size: 13, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Live Map',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteStep {
  const _RouteStep({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const SizedBox(height: 6),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.step,
    required this.isActive,
    required this.color,
  });

  final _RouteStep step;
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? AgrisellColors.surface
        : AgrisellColors.mutedText;
    final background = isActive ? color : AgrisellColors.surface;

    return Tooltip(
      message: step.label,
      excludeFromSemantics: true,
      child: Semantics(
        label: '${step.label}${isActive ? ', reached' : ', upcoming'}',
        excludeSemantics: true,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : AgrisellColors.deliveryGray,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(step.icon, color: foreground, size: 19),
        ),
      ),
    );
  }
}
