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
              style: RiderRoutePanelStyles.metricsTitle,
            ),
          ),
          if (controller.routes.length > 1)
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                dropdownColor: AppDropdownStyle.menuColor,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                style: RiderRoutePanelDetailsStyles.dropdownButtonStyle,
                iconEnabledColor: AppDropdownStyle.iconColor,
                isDense: true,
                value: controller.routes.indexOf(route),
                items: [
                  for (var index = 0; index < controller.routes.length; index++)
                    DropdownMenuItem(
                      value: index,
                      child: Text(
                        _routeLabel(controller.routes, index),
                        style: RiderRoutePanelStyles.dropdownText,
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
              minHeight: RiderRoutePanelStyles.progressMinHeight,
              borderRadius: RiderRoutePanelStyles.progressBorderRadius,
              color: AgrisellColors.authGreen,
              backgroundColor: RiderRoutePanelStyles.progressBackground,
            ),
          ),
          const SizedBox(width: RiderRoutePanelStyles.maneuverItemSpacing),
          Text(
            '${(controller.progressFraction * 100).round()}%',
            style: RiderRoutePanelStyles.progressPercent,
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
          style: RiderRoutePanelStyles.destinationText,
        ),
      ),
    ],
  );
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
    padding: RiderRoutePanelStyles.statusPadding,
    child: Row(
      children: [
        Icon(
          Icons.gps_fixed_rounded,
          size: RiderRoutePanelStyles.gpsIconSize,
          color: _qualityColor(location.quality),
        ),
        const SizedBox(width: RiderRoutePanelStyles.gpsSpacing),
        Expanded(
          child: Text(
            warning ??
                'GPS ${location.quality.name} · '
                    '±${location.accuracyMeters.toStringAsFixed(0)} m',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: RiderRoutePanelStyles.statusText,
          ),
        ),
        if (onSettings != null)
          IconButton(
            tooltip: 'Open location settings',
            visualDensity: VisualDensity.compact,
            onPressed: onSettings,
            icon: const Icon(
              Icons.settings_rounded,
              size: RiderRoutePanelStyles.settingsIconSize,
            ),
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
    padding: RiderRoutePanelStyles.statusPadding,
    child: Text(
      controller.state == RiderRouteState.loading
          ? 'Finding an accessible road route…'
          : controller.errorMessage ??
                'Select a pickup to calculate a road route.',
      textAlign: TextAlign.center,
      style: RiderRoutePanelStyles.routeStatusText,
    ),
  );
}
