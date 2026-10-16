import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_delivery_confirmation_form_styles.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../deliveries/domain/delivery_completion.dart';
import '../../../deliveries/domain/delivery_status_update.dart';
import '../../../../rider/presentation/widgets/rider_page_widgets.dart';
import 'rider_delivery_confirmation_cards.dart';
import '../styles/rider_delivery_confirmation_styles.dart';
import 'rider_delivery_evidence_capture.dart';

class RiderDeliveryConfirmationForm extends StatelessWidget {
  const RiderDeliveryConfirmationForm({
    required this.configuration,
    required this.location,
    required this.codeController,
    required this.qrController,
    required this.recipientName,
    required this.notesController,
    required this.buyerConfirmed,
    required this.signatureCaptured,
    required this.photoCaptured,
    required this.photoPreviewBytes,
    required this.photoCapturedAt,
    required this.photoLocation,
    required this.isSubmitting,
    required this.onBuyerConfirmed,
    required this.onCaptureSignature,
    required this.onCapturePhoto,
    this.cashCollectionSection,
    super.key,
  });

  final DeliveryCompletionConfiguration configuration;
  final DeliveryStatusLocation? location;
  final TextEditingController codeController;
  final TextEditingController qrController;
  final String recipientName;
  final TextEditingController notesController;
  final bool buyerConfirmed;
  final bool signatureCaptured;
  final bool photoCaptured;
  final Uint8List? photoPreviewBytes;
  final DateTime? photoCapturedAt;
  final DeliveryStatusLocation? photoLocation;
  final bool isSubmitting;
  final ValueChanged<bool> onBuyerConfirmed;
  final VoidCallback onCaptureSignature;
  final VoidCallback onCapturePhoto;
  final Widget? cashCollectionSection;

  bool _requires(DeliveryConfirmationMethod method) =>
      configuration.requiredMethods.contains(method);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      RiderDeliveryRequiredProofCard(configuration: configuration),
      const SizedBox(height: RiderDeliveryConfirmationStyles.spacing12),
      if (_requires(DeliveryConfirmationMethod.confirmationCode)) ...[
        TextField(
          controller: codeController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: RiderDeliveryConfirmationFormStyles.inputDecoration,
        ),
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing10),
      ],
      if (_requires(DeliveryConfirmationMethod.qrCode)) ...[
        TextField(
          controller: qrController,
          obscureText: true,
          decoration: RiderDeliveryConfirmationFormStyles.inputDecoration2,
        ),
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing10),
      ],
      if (_requires(DeliveryConfirmationMethod.recipientName)) ...[
        RiderDeliveryRecipientCard(recipientName: recipientName),
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing10),
      ],
      if (_requires(DeliveryConfirmationMethod.deliveryNotes)) ...[
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: RiderDeliveryConfirmationFormStyles.inputDecoration3,
        ),
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing10),
      ],
      if (_requires(DeliveryConfirmationMethod.buyerConfirmation))
        CheckboxListTile(
          contentPadding: RiderDeliveryConfirmationStyles.checkboxPadding,
          value: buyerConfirmed,
          onChanged: isSubmitting
              ? null
              : (value) => onBuyerConfirmed(value ?? false),
          title: const Text(
            'Buyer confirms the product was received',
            style: RiderDeliveryConfirmationStyles.buyerConfirmationTitle,
          ),
        ),
      if (_requires(DeliveryConfirmationMethod.buyerSignature))
        RiderDeliveryProofButton(
          label: signatureCaptured
              ? 'Buyer signature captured'
              : 'Capture buyer signature',
          icon: Icons.draw_outlined,
          complete: signatureCaptured,
          onPressed: isSubmitting ? null : onCaptureSignature,
        ),
      const SizedBox(height: RiderDeliveryConfirmationStyles.spacing8),
      RiderDeliveryEvidenceCapture(
        captured: photoCaptured,
        previewBytes: photoPreviewBytes,
        capturedAt: photoCapturedAt,
        location: photoLocation,
        enabled: !isSubmitting,
        onCapture: onCapturePhoto,
      ),
      const SizedBox(height: RiderDeliveryConfirmationStyles.spacing12),
      if (cashCollectionSection case final section?) ...[
        section,
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing12),
      ],
      RiderSurfaceCard(
        child: Text(
          location == null
              ? 'A current precise GPS fix is required.'
              : 'GPS: ${location!.latitude.toStringAsFixed(5)}, '
                    '${location!.longitude.toStringAsFixed(5)} '
                    '(±${location!.accuracyMeters.toStringAsFixed(0)} m)',
          style: RiderDeliveryConfirmationStyles.gpsText,
        ),
      ),
    ],
  );
}
