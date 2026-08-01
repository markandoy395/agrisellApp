import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_location_picker.dart';

class RiderSignUpAddressStep extends StatelessWidget {
  const RiderSignUpAddressStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final label = controller.draft.value(RiderSignUpFields.location);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm the GPS coordinates used for rider matching.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AgrisellColors.fieldFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current GPS location',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                label.isEmpty ? 'Not set yet' : label,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _selectOnMap(context),
                icon: const Icon(Icons.my_location_rounded, size: 17),
                label: const Text('Choose GPS location'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectOnMap(BuildContext context) async {
    final draft = controller.draft;
    final location = await showRiderSignUpLocationPicker(
      context,
      latitude: double.tryParse(draft.value(RiderSignUpFields.latitude)),
      longitude: double.tryParse(draft.value(RiderSignUpFields.longitude)),
      address: draft.value(RiderSignUpFields.location),
    );
    if (location == null) return;
    controller.updateLocation(
      label: location.label,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracyMeters: location.accuracyMeters,
      capturedAt: location.capturedAt,
      notes: location.notes,
    );
  }
}
