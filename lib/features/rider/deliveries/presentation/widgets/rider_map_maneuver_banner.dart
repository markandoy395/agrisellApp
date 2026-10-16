import 'package:flutter/material.dart';
import '../styles/rider_map_progress_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_route_plan.dart';
import '../controllers/rider_route_controller.dart';
import '../styles/rider_map_nav_styles.dart';

class RiderMapManeuverBanner extends StatelessWidget {
  const RiderMapManeuverBanner({
    required this.controller,
    required this.onExit,
    super.key,
  });
  final RiderRouteController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final instruction = controller.nextInstruction;
    final meters = controller.distanceToNextInstructionMeters;
    final distance = meters < 1000
        ? '${meters.round()} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Container(
          decoration: RiderMapNavStyles.bannerCard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(_icon(instruction), size: 38, color: AgrisellColors.surface),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      instruction == null ? 'Navigation' : distance,
                      style: RiderMapNavStyles.maneuverDistance,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      instruction?.text ??
                          controller.errorMessage ??
                          (controller.activeRoute == null
                              ? 'Finding your road route...'
                              : 'Follow the highlighted road route.'),
                      style: RiderMapNavStyles.maneuverInstruction,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: RiderMapProgressStyles.exitCircle,
                child: IconButton(
                  tooltip: 'Exit navigation',
                  onPressed: onExit,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AgrisellColors.surface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(RiderRouteInstruction? instruction) {
    if (instruction?.maneuverType == 'arrive') return Icons.location_on;
    if (instruction?.maneuverModifier.contains('left') ?? false)
      return Icons.turn_left;
    if (instruction?.maneuverModifier.contains('right') ?? false)
      return Icons.turn_right;
    return Icons.straight;
  }
}
