import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';

class RiderVehicleOverview extends StatelessWidget {
  const RiderVehicleOverview({
    required this.vehicle,
    required this.onEdit,
    super.key,
  });
  final RiderVehicle vehicle;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    final fields = [
      ('Type', vehicle.vehicleType),
      ('Brand', vehicle.vehicleBrand ?? 'Not provided'),
      ('Model', vehicle.vehicleModel),
      ('Color', vehicle.vehicleColor),
      ('Plate number', vehicle.plateNumber),
      ('Registration number', vehicle.registrationNumber ?? 'Not provided'),
      (
        'Capacity',
        vehicle.capacityKg > 0
            ? '${vehicle.capacityKg} kg'
            : 'Set your cargo capacity',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RiderProfileCard(
          child: Row(
            children: [
              const Expanded(
                child: Icon(
                  Icons.two_wheeler_rounded,
                  size: 85,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              Flexible(
                child: OutlinedButton.icon(
                  style: RiderProfileDesignStyles.secondary,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit vehicle'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 330 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? 1
                : 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final field in fields)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 10) / columns,
                    child: RiderProfileCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.$1,
                            style: RiderProfileDesignStyles.caption,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            field.$2.isEmpty ? 'Not provided' : field.$2,
                            style: RiderProfileDesignStyles.body,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        RiderProfileSection(
          title: 'Verification',
          icon:
              vehicle.verificationStatus ==
                  RiderVehicleVerificationStatus.verified
              ? Icons.check_circle_rounded
              : Icons.pending_outlined,
          children: [
            Text(switch (vehicle.verificationStatus) {
              RiderVehicleVerificationStatus.verified =>
                'Vehicle details are verified.',
              RiderVehicleVerificationStatus.pending =>
                'Vehicle details are pending verification.',
              RiderVehicleVerificationStatus.rejected =>
                'Vehicle details require review.',
            }, style: RiderProfileDesignStyles.muted),
          ],
        ),
      ],
    );
  }
}
