import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

Future<RiderProfile?> showRiderProfileEditDialog(
  BuildContext context,
  RiderProfile profile,
) async {
  final controllers = [
    TextEditingController(text: profile.firstName),
    TextEditingController(text: profile.lastName),
    TextEditingController(text: profile.contactNumber),
    TextEditingController(text: profile.licenseNumber),
    TextEditingController(text: profile.vehiclePlateNumber),
  ];
  String? error;
  final updated = await showDialog<RiderProfile>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit rider profile'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in _fields(controllers, profile)) ...[
                  TextField(
                    controller: item.controller,
                    keyboardType: item.type,
                    decoration: InputDecoration(labelText: item.label),
                  ),
                  if (identical(item.controller, controllers[2]))
                    PhoneNumberSyncControl(controller: controllers[2]),
                  const SizedBox(height: 8),
                ],
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(
                      color: AgrisellColors.statusRedText,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final requiredControllers = <TextEditingController>[
                ...controllers.take(3),
                if (profile.vehicleType.requiresLicense) controllers[3],
                if (profile.vehicleType.requiresPlate) controllers[4],
              ];
              if (requiredControllers.any((item) => item.text.trim().isEmpty)) {
                setDialogState(
                  () => error = 'Complete the required rider fields.',
                );
                return;
              }
              Navigator.of(context).pop(
                profile.copyWith(
                  fullName:
                      '${controllers[0].text.trim()} ${controllers[1].text.trim()}',
                  contactNumber: controllers[2].text.trim(),
                  licenseNumber: profile.vehicleType.requiresLicense
                      ? controllers[3].text.trim().toUpperCase()
                      : profile.licenseNumber,
                  vehiclePlateNumber: profile.vehicleType.requiresPlate
                      ? controllers[4].text.trim().toUpperCase()
                      : profile.vehiclePlateNumber,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  for (final controller in controllers) {
    controller.dispose();
  }
  return updated;
}

List<_ProfileField> _fields(
  List<TextEditingController> controllers,
  RiderProfile profile,
) => [
  _ProfileField('First name', controllers[0], TextInputType.name),
  _ProfileField('Last name', controllers[1], TextInputType.name),
  _ProfileField('Contact number', controllers[2], TextInputType.phone),
  if (profile.vehicleType.requiresLicense)
    _ProfileField('License number', controllers[3], TextInputType.text),
  if (profile.vehicleType.requiresPlate)
    _ProfileField('Vehicle plate number', controllers[4], TextInputType.text),
];

class _ProfileField {
  const _ProfileField(this.label, this.controller, this.type);
  final String label;
  final TextEditingController controller;
  final TextInputType type;
}
