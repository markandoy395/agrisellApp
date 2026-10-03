import 'package:agresell_app/features/shared/location/presentation/styles/location_gps_status_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';

class LocationGpsStatus extends StatelessWidget {
  const LocationGpsStatus({required this.controller, super.key});

  final GpsSelectionController controller;

  @override
  Widget build(BuildContext context) {
    final accuracy = controller.bestPosition?.accuracy;
    final (icon, title, message, action) = switch (controller.state) {
      GpsSelectionState.ready => (
        Icons.gps_fixed_rounded,
        'Accurate GPS location found',
        'Accuracy: ${accuracy!.toStringAsFixed(0)} m',
        null,
      ),
      GpsSelectionState.poorAccuracy => (
        Icons.gps_not_fixed_rounded,
        'Finding a more accurate location…',
        'Current accuracy: ${accuracy!.toStringAsFixed(0)} m. Move near a window or open area.',
        null,
      ),
      GpsSelectionState.serviceDisabled => (
        Icons.location_disabled_outlined,
        'GPS is disabled',
        'Turn on device location services, then try again.',
        controller.openLocationSettings,
      ),
      GpsSelectionState.permissionDenied => (
        Icons.location_off_outlined,
        'Location permission denied',
        'Fine Location permission is required for an exact point.',
        controller.start,
      ),
      GpsSelectionState.permissionDeniedForever => (
        Icons.settings_outlined,
        'Location permission blocked',
        'Allow Fine Location in the app settings.',
        controller.openAppSettings,
      ),
      GpsSelectionState.preciseLocationDisabled => (
        Icons.gps_off_rounded,
        'Precise location disabled',
        'Enable Precise Location or Fine Location in app settings.',
        controller.openAppSettings,
      ),
      GpsSelectionState.error => (
        Icons.error_outline,
        'GPS location unavailable',
        controller.errorMessage ?? 'Try again in an open area.',
        controller.start,
      ),
      _ => (
        Icons.gps_fixed_rounded,
        'Finding your precise GPS location',
        'Waiting for improved satellite accuracy…',
        null,
      ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: LocationGpsStatusStyles.containerDecoration,
      child: Row(
        children: [
          Icon(icon, size: 19, color: AgrisellColors.authGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SharedPresentationStyles.captionBold),
                Text(message, style: SharedPresentationStyles.mutedCaption),
              ],
            ),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Fix')),
        ],
      ),
    );
  }
}
