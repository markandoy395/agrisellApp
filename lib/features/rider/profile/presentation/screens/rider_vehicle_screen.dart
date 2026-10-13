import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import '../widgets/rider_vehicle_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle details')),
      backgroundColor: AgrisellColors.homeBackground,
      body: vehicle == null
          ? const Center(child: Text('No Rider vehicle is available.'))
          : RiderVehicleContent(
              children: [
                RiderCapacityEditor(
                  vehicle: vehicle,
                  onSave: (capacity) async {
                    await RiderRegistrationService.instance.saveCapacity(
                      capacity,
                    );
                    if (mounted) setState(() {});
                  },
                ),
                _row('Type', vehicle.vehicleType),
                _row('Brand', vehicle.vehicleBrand ?? 'Not provided'),
                _row('Model', vehicle.vehicleModel),
                _row('Color', vehicle.vehicleColor),
                _row('Plate number', vehicle.plateNumber),
                _row(
                  'Registration number',
                  vehicle.registrationNumber ?? 'Not provided',
                ),
                _row(
                  'Capacity',
                  vehicle.capacityKg > 0
                      ? '${vehicle.capacityKg} kg'
                      : 'Set your cargo capacity',
                ),
                _row('Verification', vehicle.verificationStatus.name),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _edit(vehicle),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(_saving ? 'Saving...' : 'Edit vehicle'),
                ),
              ],
            ),
    );
  }

  Widget _row(String label, String value) => Card(
    child: ListTile(
      title: Text(label, style: SharedPresentationStyles.caption),
      subtitle: Text(value, style: SharedPresentationStyles.bodyBold),
    ),
  );

  Future<void> _edit(RiderVehicle vehicle) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => RiderVehicleEditDialog(vehicle: vehicle),
    );
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
