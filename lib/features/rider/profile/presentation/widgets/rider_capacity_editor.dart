import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_cargo_capacity_policy.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_capacity_editor_styles.dart';

class RiderCapacityEditor extends StatefulWidget {
  const RiderCapacityEditor({
    required this.vehicle,
    required this.onSave,
    super.key,
  });
  final RiderVehicle vehicle;
  final Future<void> Function(double) onSave;
  @override
  State<RiderCapacityEditor> createState() => _RiderCapacityEditorState();
}

class _RiderCapacityEditorState extends State<RiderCapacityEditor> {
  late final _controller = TextEditingController(
    text: widget.vehicle.capacityKg > 0 ? '${widget.vehicle.capacityKg}' : '',
  );
  var _saving = false;
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maximum = RiderCargoCapacityPolicy.maximum(
      widget.vehicle.vehicleType,
      serverMaximum: widget.vehicle.maximumCapacityKg,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Usable cargo capacity',
              style: RiderCapacityEditorStyles.title,
            ),
            const SizedBox(height: 8),
            const Text(
              'Required to accept multiple orders. Previously registered riders '
              'must save this once. The combined weight of all active orders '
              'must stay within your saved capacity.',
              style: SharedPresentationStyles.caption,
            ),
            const SizedBox(height: 8),
            Text(
              maximum == null
                  ? 'Capacity policy is unavailable for this vehicle type.'
                  : 'Vehicle ceiling: ${maximum.toStringAsFixed(0)} kg. Enter the cargo weight your own vehicle can carry after allowing for you, passengers and accessories.',
              style: SharedPresentationStyles.caption,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('rider-capacity-field'),
              controller: _controller,
              enabled: !_saving && maximum != null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: RiderCapacityEditorStyles.decoration(_error),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('rider-capacity-save'),
              onPressed: _saving || maximum == null ? null : _save,
              style: RiderCapacityEditorStyles.saveButton,
              child: Text(_saving ? 'Saving...' : 'Save cargo capacity'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final error = RiderCargoCapacityPolicy.error(
      _controller.text,
      widget.vehicle.vehicleType,
      serverMaximum: widget.vehicle.maximumCapacityKg,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(double.parse(_controller.text.trim()));
    } on Exception catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
