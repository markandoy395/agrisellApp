import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/delivery_status_update.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';

class RiderDeliveryEvidenceCapture extends StatelessWidget {
  const RiderDeliveryEvidenceCapture({
    required this.captured,
    required this.previewBytes,
    required this.capturedAt,
    required this.location,
    required this.enabled,
    required this.onCapture,
    super.key,
  });

  final bool captured;
  final Uint8List? previewBytes;
  final DateTime? capturedAt;
  final DeliveryStatusLocation? location;
  final bool enabled;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Delivery evidence',
          style: SharedPresentationStyles.subtitleExtraBold,
        ),
        const SizedBox(height: 5),
        const Text(
          'Take a photo with the camera at the delivery location.',
          style: SharedPresentationStyles.caption,
        ),
        if (previewBytes case final bytes?) ...[
          const SizedBox(height: 10),
          Semantics(
            button: true,
            label: 'Preview captured delivery evidence',
            child: InkWell(
              onTap: () => _preview(context, bytes),
              borderRadius: BorderRadius.circular(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  bytes,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
        if (captured) ...[
          const SizedBox(height: 8),
          Text(_metadata, style: SharedPresentationStyles.captionSemibold),
        ],
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: OutlinedButton.icon(
            onPressed: enabled ? onCapture : null,
            icon: Icon(
              captured ? Icons.refresh_rounded : Icons.camera_alt_outlined,
              size: 18,
            ),
            label: Text(
              captured
                  ? 'Retake delivery evidence'
                  : 'Capture delivery evidence',
            ),
          ),
        ),
      ],
    ),
  );

  String get _metadata {
    final parts = <String>[];
    if (capturedAt != null) {
      final local = capturedAt!.toLocal();
      parts.add(
        'Captured ${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}',
      );
    }
    if (location != null) {
      parts.add(
        'GPS ${location!.latitude.toStringAsFixed(5)}, '
        '${location!.longitude.toStringAsFixed(5)}',
      );
    }
    return parts.isEmpty ? 'Evidence captured securely' : parts.join(' â€¢ ');
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _preview(BuildContext context, Uint8List bytes) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractiveViewer(
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close preview'),
                ),
              ],
            ),
          ),
        ),
      );
}
