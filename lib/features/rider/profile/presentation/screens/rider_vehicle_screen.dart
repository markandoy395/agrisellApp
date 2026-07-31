import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';

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
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _row('Type', vehicle.vehicleType),
                _row('Brand', vehicle.vehicleBrand ?? 'Not provided'),
                _row('Model', vehicle.vehicleModel),
                _row('Color', vehicle.vehicleColor),
                _row('Plate number', vehicle.plateNumber),
                _row(
                  'Registration number',
                  vehicle.registrationNumber ?? 'Not provided',
                ),
                _row('Capacity', '${vehicle.capacityKg} kg'),
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
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
  );

  Future<void> _edit(RiderVehicle vehicle) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => _VehicleEditDialog(vehicle: vehicle),
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

class _VehicleEditDialog extends StatefulWidget {
  const _VehicleEditDialog({required this.vehicle});
  final RiderVehicle vehicle;
  @override
  State<_VehicleEditDialog> createState() => _VehicleEditDialogState();
}

class _VehicleEditDialogState extends State<_VehicleEditDialog> {
  late final List<TextEditingController> _controllers = [
    TextEditingController(text: widget.vehicle.vehicleBrand),
    TextEditingController(text: widget.vehicle.vehicleModel),
    TextEditingController(text: widget.vehicle.vehicleColor),
    TextEditingController(text: widget.vehicle.plateNumber),
    TextEditingController(text: widget.vehicle.registrationNumber),
    TextEditingController(text: '${widget.vehicle.capacityKg}'),
  ];
  String? _error;
  bool get _requiresRegistration =>
      widget.vehicle.vehicleType != 'bicycle' &&
      widget.vehicle.vehicleType != 'eBike';

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit vehicle'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < _labels.length; index++)
            if (_requiresRegistration || (index != 3 && index != 4))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _controllers[index],
                  decoration: InputDecoration(labelText: _labels[index]),
                ),
              ),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.statusRedText,
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  void _save() {
    final values = _controllers.map((item) => item.text.trim()).toList();
    final requiredValues = <String>[
      values[1],
      values[2],
      if (_requiresRegistration) values[3],
      if (_requiresRegistration) values[4],
      values[5],
    ];
    if (requiredValues.any((value) => value.isEmpty)) {
      setState(() => _error = 'Complete all required vehicle fields.');
      return;
    }
    Navigator.pop(context, values);
  }
}

const _labels = [
  'Brand (optional)',
  'Model',
  'Color',
  'Plate number',
  'Registration number',
  'Capacity (kg)',
];
