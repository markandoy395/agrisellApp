part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _DeliveryRouteTracker extends StatelessWidget {
  const _DeliveryRouteTracker({required this.status});

  final PlacedOrderStatus status;

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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: LayoutBuilder(
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
