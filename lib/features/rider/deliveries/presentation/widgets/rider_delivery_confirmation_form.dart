import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../deliveries/domain/delivery_completion.dart';
import '../../../deliveries/domain/delivery_status_update.dart';
import '../../../../rider/presentation/widgets/rider_page_widgets.dart';
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
    required this.onSubmit,
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
  final VoidCallback onSubmit;
  final Widget? cashCollectionSection;

  bool _requires(DeliveryConfirmationMethod method) =>
      configuration.requiredMethods.contains(method);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      RiderSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required delivery proof',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final method in configuration.requiredMethods)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '• ${method.label}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            if (!configuration.requiredMethods.contains(
              DeliveryConfirmationMethod.handoverPhoto,
            ))
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  'â€¢ Delivery evidence photo',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (_requires(DeliveryConfirmationMethod.confirmationCode)) ...[
        TextField(
          controller: codeController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Delivery confirmation code',
            helperText: 'The code is validated securely and is never logged.',
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (_requires(DeliveryConfirmationMethod.qrCode)) ...[
        TextField(
          controller: qrController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'QR code value'),
        ),
        const SizedBox(height: 10),
      ],
      if (_requires(DeliveryConfirmationMethod.recipientName)) ...[
        RiderSurfaceCard(
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recipient name',
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      recipientName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'From the buyer information',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (_requires(DeliveryConfirmationMethod.deliveryNotes)) ...[
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Delivery notes'),
        ),
        const SizedBox(height: 10),
      ],
      if (_requires(DeliveryConfirmationMethod.buyerConfirmation))
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: buyerConfirmed,
          onChanged: isSubmitting
              ? null
              : (value) => onBuyerConfirmed(value ?? false),
          title: const Text(
            'Buyer confirms the product was received',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      if (_requires(DeliveryConfirmationMethod.buyerSignature))
        _ProofButton(
          label: signatureCaptured
              ? 'Buyer signature captured'
              : 'Capture buyer signature',
          icon: Icons.draw_outlined,
          complete: signatureCaptured,
          onPressed: isSubmitting ? null : onCaptureSignature,
        ),
      const SizedBox(height: 8),
      RiderDeliveryEvidenceCapture(
        captured: photoCaptured,
        previewBytes: photoPreviewBytes,
        capturedAt: photoCapturedAt,
        location: photoLocation,
        enabled: !isSubmitting,
        onCapture: onCapturePhoto,
      ),
      const SizedBox(height: 12),
      if (cashCollectionSection case final section?) ...[
        section,
        const SizedBox(height: 12),
      ],
      RiderSurfaceCard(
        child: Text(
          location == null
              ? 'A current precise GPS fix is required.'
              : 'GPS: ${location!.latitude.toStringAsFixed(5)}, '
                    '${location!.longitude.toStringAsFixed(5)} '
                    '(±${location!.accuracyMeters.toStringAsFixed(0)} m)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 38,
        child: FilledButton(
          onPressed: isSubmitting ? null : onSubmit,
          child: Text(isSubmitting ? 'Confirming...' : 'Complete delivery'),
        ),
      ),
    ],
  );
}

class _ProofButton extends StatelessWidget {
  const _ProofButton({
    required this.label,
    required this.icon,
    required this.complete,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool complete;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(complete ? Icons.check_circle_outline : icon, size: 18),
    label: Text(label),
  );
}
