part of 'rider_route_panel.dart';

class _RouteMetrics extends StatelessWidget {
  const _RouteMetrics({
    required this.controller,
    required this.route,
    required this.selectedRequest,
  });

  final RiderRouteController controller;
  final RiderRoutePlan route;
  final DeliveryRequest? selectedRequest;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (controller.nextInstruction case final instruction?) ...[
        const SizedBox(height: 3),
        _NextManeuverCard(
          instruction: instruction,
          distanceMeters: controller.distanceToNextInstructionMeters,
        ),
      ],
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: Text(
              '${controller.remainingDistanceKm.toStringAsFixed(1)} km · '
              '${controller.remainingTravelMinutes} min · '
              'ETA ${_time(controller.estimatedArrival)}',
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (controller.routes.length > 1)
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                dropdownColor: AppDropdownStyle.menuColor,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                style: AppDropdownStyle.textStyle.copyWith(fontSize: 12),
                iconEnabledColor: AppDropdownStyle.iconColor,
                isDense: true,
                value: controller.routes.indexOf(route),
                items: [
                  for (var index = 0; index < controller.routes.length; index++)
                    DropdownMenuItem(
                      value: index,
                      child: Text(
                        _routeLabel(controller.routes, index),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
                onChanged: (index) {
                  if (index != null) controller.selectRoute(index);
                },
              ),
            ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: controller.progressFraction,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
              color: AgrisellColors.authGreen,
              backgroundColor: AgrisellColors.authGreen.withValues(alpha: 0.14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(controller.progressFraction * 100).round()}%',
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${controller.isUsingCachedRoute ? 'Saved route · ' : ''}'
          'To ${_routeDestination(selectedRequest, route.destinationKey, route.destinationRoadName)}'
          '${route.instructions.isEmpty ? '' : '\nNext: ${route.instructions.first.text}'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
}

class _NextManeuverCard extends StatelessWidget {
  const _NextManeuverCard({
    required this.instruction,
    required this.distanceMeters,
  });

  final RiderRouteInstruction instruction;
  final double distanceMeters;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Next direction: ${instruction.text}',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(_maneuverIcon(instruction), color: AgrisellColors.authGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                instruction.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _distanceLabel(distanceMeters),
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _maneuverIcon(RiderRouteInstruction instruction) =>
    switch (instruction.maneuverType) {
      'arrive' => Icons.location_on_rounded,
      'roundabout' || 'rotary' => Icons.roundabout_right_rounded,
      'merge' => Icons.merge_type_rounded,
      'turn' || 'fork' =>
        instruction.maneuverModifier.contains('left')
            ? Icons.turn_left_rounded
            : instruction.maneuverModifier.contains('right')
            ? Icons.turn_right_rounded
            : Icons.straight_rounded,
      _ => Icons.straight_rounded,
    };

String _distanceLabel(double meters) {
  if (meters <= 0) return 'Now';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

class _GpsRouteStatus extends StatelessWidget {
  const _GpsRouteStatus({
    required this.location,
    required this.warning,
    required this.onSettings,
  });
  final RiderDeviceLocation location;
  final String? warning;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(
          Icons.gps_fixed_rounded,
          size: 14,
          color: _qualityColor(location.quality),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            warning ??
                'GPS ${location.quality.name} · '
                    '±${location.accuracyMeters.toStringAsFixed(0)} m',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ),
        if (onSettings != null)
          IconButton(
            tooltip: 'Open location settings',
            visualDensity: VisualDensity.compact,
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded, size: 18),
          ),
      ],
    ),
  );
}

class _RouteStatus extends StatelessWidget {
  const _RouteStatus({required this.controller});
  final RiderRouteController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      controller.state == RiderRouteState.loading
          ? 'Finding an accessible road route…'
          : controller.errorMessage ??
                'Select a pickup to calculate a road route.',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
    ),
  );
}
