import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/delivery_proof_storage.dart';
import '../../domain/delivery_proof.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';

class RiderDeliveryEvidenceView extends StatelessWidget {
  const RiderDeliveryEvidenceView({required this.proof, super.key});

  final DeliveryProof proof;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery evidence',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _EvidenceImage(reference: proof.secureReference),
        const SizedBox(height: 8),
        Text(
          _metadata,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  String get _metadata {
    final captured = proof.capturedAt.toLocal();
    final location = proof.latitude == null || proof.longitude == null
        ? 'GPS unavailable'
        : 'GPS ${proof.latitude!.toStringAsFixed(5)}, '
              '${proof.longitude!.toStringAsFixed(5)}';
    return 'Captured ${captured.year}-${_two(captured.month)}-'
        '${_two(captured.day)} ${_two(captured.hour)}:${_two(captured.minute)}'
        ' â€¢ $location';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _EvidenceImage extends StatelessWidget {
  const _EvidenceImage({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    if (reference.startsWith('http://') || reference.startsWith('https://')) {
      return _previewable(
        context,
        Image.network(reference, fit: BoxFit.cover, errorBuilder: _error),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: DeliveryProofStorage().readLocalEvidence(reference),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return _error(context, Object(), null);
        return _previewable(context, Image.memory(bytes, fit: BoxFit.cover));
      },
    );
  }

  Widget _previewable(BuildContext context, Widget image) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(width: double.infinity, height: 180, child: image),
  );

  Widget _error(BuildContext context, Object error, StackTrace? stackTrace) =>
      const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Evidence preview is temporarily unavailable.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
}
