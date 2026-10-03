part of 'rider_route_panel.dart';

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
      decoration: RiderRoutePanelStyles.maneuverDecoration,
      child: Padding(
        padding: RiderRoutePanelStyles.maneuverPadding,
        child: Row(
          children: [
            Icon(_maneuverIcon(instruction), color: AgrisellColors.authGreen),
            const SizedBox(width: RiderRoutePanelStyles.maneuverItemSpacing),
            Expanded(
              child: Text(
                instruction.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: RiderRoutePanelStyles.maneuverInstruction,
              ),
            ),
            const SizedBox(width: RiderRoutePanelStyles.maneuverItemSpacing),
            Text(
              _distanceLabel(distanceMeters),
              style: RiderRoutePanelStyles.maneuverDistance,
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
