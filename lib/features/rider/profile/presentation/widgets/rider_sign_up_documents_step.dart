import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_document_tile.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';

class RiderSignUpDocumentsStep extends StatelessWidget {
  const RiderSignUpDocumentsStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final type = RiderVehicleType.values
        .where(
          (item) =>
              item.name ==
              controller.draft.value(RiderSignUpFields.vehicleType),
        )
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload clear credentials so Agrisell can verify your identity and vehicle.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
        const SizedBox(height: 12),
        RiderSignUpTextField(
          label: type?.requiresLicense ?? false
              ? 'Driver\'s license number'
              : 'License number (optional)',
          value: controller.licenseNumber,
          helper: 'This value is not saved in the local draft.',
          onChanged: (value) =>
              controller.updateSensitive(licenseNumber: value),
        ),
        const SizedBox(height: 12),
        for (final documentType in _requiredDocuments(type))
          RiderSignUpDocumentTile(
            type: documentType,
            document: controller.draft.documents[documentType],
            required: true,
            onPick: () => _pick(context, documentType),
            onRemove: () => controller.removeDocument(documentType),
          ),
      ],
    );
  }

  List<RiderDraftDocumentType> _requiredDocuments(RiderVehicleType? type) => [
    RiderDraftDocumentType.validId,
    if (type?.requiresLicense ?? false) RiderDraftDocumentType.driversLicense,
    if (type?.requiresPlate ?? false) ...[
      RiderDraftDocumentType.vehicleOr,
      RiderDraftDocumentType.vehicleCr,
      RiderDraftDocumentType.vehiclePhoto,
    ],
  ];

  Future<void> _pick(BuildContext context, RiderDraftDocumentType type) async {
    final source = await showRiderDocumentSourceSheet(context);
    if (source != null) await controller.addDocument(type, source);
  }
}
