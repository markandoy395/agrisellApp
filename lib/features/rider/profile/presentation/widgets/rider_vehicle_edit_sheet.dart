import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import '../../domain/rider_vehicle.dart';
import '../../domain/rider_cargo_capacity_policy.dart';
import '../styles/rider_vehicle_screen_styles.dart';
import 'rider_vehicle_edit_sheet_layout.dart';

Future<List<String>?> showRiderVehicleEditSheet(
  BuildContext context,
  RiderVehicle vehicle,
) => showModalBottomSheet<List<String>>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: RiderVehicleScreenStyles.sheetBackground,
  shape: RiderVehicleScreenStyles.sheetShape,
  clipBehavior: Clip.antiAlias,
  builder: (_) => RiderVehicleEditSheet(vehicle: vehicle),
);

class RiderVehicleEditSheet extends StatefulWidget {
  const RiderVehicleEditSheet({required this.vehicle, super.key});
  final RiderVehicle vehicle;
  @override
  State<RiderVehicleEditSheet> createState() => _RiderVehicleEditSheetState();
}

class _RiderVehicleEditSheetState extends State<RiderVehicleEditSheet> {
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
  Widget build(BuildContext context) => RiderVehicleEditSheetLayout(
    onSave: _save,
    fields: [
      for (var index = 0; index < _labels.length; index++)
        if (_requiresRegistration || (index != 3 && index != 4))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              key: ValueKey('vehicle-edit-$index'),
              controller: _controllers[index],
              keyboardType: index == 5
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: RiderVehicleScreenStyles.inputDecoration(
                _labels,
                index,
              ),
            ),
          ),
      if (_error != null)
        Text(_error!, style: SharedPresentationStyles.errorCaption),
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
    final error = RiderCargoCapacityPolicy.error(
      values[5],
      widget.vehicle.vehicleType,
      serverMaximum: widget.vehicle.maximumCapacityKg,
    );
    if (error != null) {
      setState(() => _error = error);
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
