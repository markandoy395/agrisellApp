import '../styles/rider_profile_design_styles.dart';
import '../widgets/rider_vehicle_overview.dart';
import '../widgets/rider_vehicle_edit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_capacity_editor.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_vehicle_content.dart';

class RiderVehicleScreen extends StatefulWidget {
  const RiderVehicleScreen({super.key});

  @override
  State<RiderVehicleScreen> createState() => _RiderVehicleScreenState();
}

class _RiderVehicleScreenState extends State<RiderVehicleScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final vehicle = RiderRegistrationService.instance.currentVehicle;
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(appBarTheme: RiderProfileDesignStyles.appBar),
      child: Scaffold(
        appBar: AppBar(title: const Text('Vehicle details')),
        backgroundColor: RiderProfileDesignStyles.background,
        body: vehicle == null
            ? const Center(child: Text('No Rider vehicle is available.'))
            : RiderVehicleContent(
                children: [
                  RiderVehicleOverview(
                    vehicle: vehicle,
                    onEdit: _saving ? null : () => _edit(vehicle),
                  ),
                  const SizedBox(height: 16),
                  RiderCapacityEditor(
                    vehicle: vehicle,
                    onSave: (capacity) async {
                      await RiderRegistrationService.instance.saveCapacity(
                        capacity,
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _edit(RiderVehicle vehicle) async {
    final values = await showRiderVehicleEditSheet(context, vehicle);
    if (values == null || !mounted) return;
    setState(() => _saving = true);
    try {
      await RiderRegistrationService.instance.saveVehicle(
        vehicle.copyWith(
          vehicleBrand: values[0],
          vehicleModel: values[1],
          vehicleColor: values[2],
          plateNumber: values[3].toUpperCase(),
          registrationNumber: values[4].toUpperCase(),
          capacityKg: double.tryParse(values[5]) ?? 0,
        ),
      );
      if (mounted) setState(() {});
    } on RiderRegistrationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showAppSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
