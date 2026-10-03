part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _RouteStep {
  const _RouteStep({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: DeliveryRouteTrackerStyles.routeLineDecoration(color),
    child: const SizedBox(height: 6),
  );
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

    return Tooltip(
      message: step.label,
      excludeFromSemantics: true,
      child: Semantics(
        label: '${step.label}${isActive ? ', reached' : ', upcoming'}',
        excludeSemantics: true,
        child: Container(
          width: 38,
          height: 38,
          decoration: DeliveryRouteTrackerStyles.routeStopDecoration(
            isActive: isActive,
            color: color,
          ),
          child: Icon(step.icon, color: foreground, size: 19),
        ),
      ),
    );
  }
}
