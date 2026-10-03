import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_manual_arrival_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

class RiderManualArrivalOverride {
  const RiderManualArrivalOverride({
    required this.reasonCode,
    required this.reasonLabel,
    required this.notes,
  });

  final String reasonCode;
  final String reasonLabel;
  final String notes;
}

class RiderManualArrivalDialog extends StatefulWidget {
  const RiderManualArrivalDialog({required this.location, super.key});

  static const reasons = <String, String>{
    'gps_signal_blocked': 'GPS signal is blocked',
    'location_inaccurate': 'Location is inaccurate',
    'pickup_pin_incorrect': 'Pickup pin is incorrect',
    'delivery_pin_incorrect': 'Delivery pin is incorrect',
    'access_point_differs': 'Access point differs from marker',
    'other': 'Other location problem',
  };

  final DeliveryStatusLocation location;

  @override
  State<RiderManualArrivalDialog> createState() =>
      _RiderManualArrivalDialogState();
}

class _RiderManualArrivalDialogState extends State<RiderManualArrivalDialog> {
  final _notes = TextEditingController();
  String _reason = RiderManualArrivalDialog.reasons.keys.first;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Manual arrival override'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence: ${widget.location.latitude.toStringAsFixed(5)}, '
          '${widget.location.longitude.toStringAsFixed(5)} · '
          '±${widget.location.accuracyMeters.toStringAsFixed(0)} m · '
          '${widget.location.timestamp?.toLocal() ?? 'timestamp unavailable'}',
          style: SharedPresentationStyles.caption,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          dropdownColor: AppDropdownStyle.menuColor,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          style: AppDropdownStyle.textStyle,
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: _reason,
          decoration: RiderManualArrivalDialogStyles.inputDecoration,
          items: [
            for (final entry in RiderManualArrivalDialog.reasons.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (value) => setState(() => _reason = value ?? _reason),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          onChanged: (_) => setState(() {}),
          minLines: 2,
          maxLines: 3,
          style: SharedPresentationStyles.caption,
          decoration: RiderManualArrivalDialogStyles.inputDecoration2,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _reason == 'other' && _notes.text.trim().isEmpty
            ? null
            : () => Navigator.of(context).pop(
                RiderManualArrivalOverride(
                  reasonCode: _reason,
                  reasonLabel: RiderManualArrivalDialog.reasons[_reason]!,
                  notes: _notes.text.trim(),
                ),
              ),
        child: const Text('Record override'),
      ),
    ],
  );
}

Future<RiderManualArrivalOverride?> showRiderManualArrivalDialog(
  BuildContext context, {
  required DeliveryStatusLocation location,
}) => showDialog<RiderManualArrivalOverride>(
  context: context,
  builder: (_) => RiderManualArrivalDialog(location: location),
);
