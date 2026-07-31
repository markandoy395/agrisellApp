import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/rider_availability_warning_presentation.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/rider_environment_presentation.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';

class RiderAvailabilityCard extends StatelessWidget {
  const RiderAvailabilityCard({required this.controller, super.key});

  final RiderAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final availability = controller.displayedAvailability;
    final warning = controller.warning;
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availability',
                      style: TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    RiderStatusPill(
                      label: availability.displayLabel,
                      icon: availability.icon,
                      backgroundColor: availability.isOnline
                          ? AgrisellColors.statusGreenBackground
                          : AgrisellColors.deliveryGray,
                      foregroundColor: availability.isOnline
                          ? AgrisellColors.statusGreenText
                          : AgrisellColors.mutedText,
                    ),
                  ],
                ),
              ),
              if (controller.isBusy)
                const Padding(
                  padding: EdgeInsets.only(right: 9),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              Semantics(
                label: availability.isOnline ? 'Go offline' : 'Go online',
                child: Switch.adaptive(
                  value: availability.isOnline,
                  onChanged: controller.isBusy
                      ? null
                      : (value) => _setAvailability(context, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EnvironmentPill(
                icon: Icons.gps_fixed_rounded,
                label: controller.gpsStatus.displayLabel,
                isHealthy: controller.gpsStatus == RiderGpsStatus.ready,
                isWarning: controller.gpsStatus == RiderGpsStatus.poorAccuracy,
              ),
              _EnvironmentPill(
                icon: Icons.wifi_rounded,
                label: controller.internetStatus.displayLabel,
                isHealthy:
                    controller.internetStatus == RiderInternetStatus.online,
                isWarning: false,
              ),
            ],
          ),
          if (warning != null) ...[
            const SizedBox(height: 12),
            _AvailabilityWarning(
              message: warning.displayMessage,
              onDismissed: controller.clearWarning,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setAvailability(BuildContext context, bool value) async {
    final result = await controller.setOnline(value);
    if (!context.mounted || !result.isSuccess) return;
    final label = controller.availability == RiderAvailability.offline
        ? 'You are now offline.'
        : 'Availability updated to ${controller.availability.displayLabel}.';
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(label)));
  }
}

class _EnvironmentPill extends StatelessWidget {
  const _EnvironmentPill({
    required this.icon,
    required this.label,
    required this.isHealthy,
    required this.isWarning,
  });

  final IconData icon;
  final String label;
  final bool isHealthy;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final foreground = isHealthy
        ? AgrisellColors.statusGreenText
        : isWarning
        ? AgrisellColors.statusOrangeText
        : AgrisellColors.statusRedText;
    final background = isHealthy
        ? AgrisellColors.statusGreenBackground
        : isWarning
        ? AgrisellColors.statusOrangeBackground
        : AgrisellColors.statusRedBackground;
    return RiderStatusPill(
      label: label,
      icon: icon,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

class _AvailabilityWarning extends StatelessWidget {
  const _AvailabilityWarning({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.statusOrangeBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AgrisellColors.statusOrangeText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AgrisellColors.statusOrangeText,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Dismiss warning',
            onPressed: onDismissed,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    ),
  );
}
