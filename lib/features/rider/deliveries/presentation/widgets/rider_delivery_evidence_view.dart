import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import '../../data/delivery_proof_storage.dart';
import '../../data/pickup_proof_storage.dart';
import '../../data/rider_proof_image_reference.dart';
import '../../domain/delivery_proof.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';

class RiderDeliveryEvidenceView extends StatelessWidget {
  const RiderDeliveryEvidenceView({required this.proof, super.key});
  final DeliveryProof proof;
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Delivery evidence',
    icon: Icons.camera_alt_outlined,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 74,
              height: 74,
              child: _EvidenceImage(reference: proof.secureReference),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proof.type == DeliveryProofType.productPhoto
                      ? 'Pickup photo'
                      : 'Delivery photo',
                  style: RiderDeliveryReferenceStyles.strongCaption,
                ),
                const SizedBox(height: 4),
                Text(
                  riderDetailDate(context, proof.capturedAt),
                  style: RiderDeliveryReferenceStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  proof.latitude == null || proof.longitude == null
                      ? 'GPS unavailable'
                      : 'GPS: ${proof.latitude!.toStringAsFixed(5)}, ${proof.longitude!.toStringAsFixed(5)}',
                  style: RiderDeliveryReferenceStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class _EvidenceImage extends StatefulWidget {
  const _EvidenceImage({required this.reference});
  final String reference;
  @override
  State<_EvidenceImage> createState() => _EvidenceImageState();
}

class _EvidenceImageState extends State<_EvidenceImage> {
  Future<Uint8List?>? _local;
  String? get _url => riderProofImageUrl(widget.reference);
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _EvidenceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference) _load();
  }

  void _load() => _local = _url != null ? null : _readLocal();

  Future<Uint8List?> _readLocal() async {
    if (widget.reference.startsWith('local-secure://pickup/')) {
      final file = await PickupProofStorage().resolveLocalPhoto(
        widget.reference,
      );
      return file?.readAsBytes();
    }
    return DeliveryProofStorage().readLocalEvidence(widget.reference);
  }

  @override
  Widget build(BuildContext context) {
    if (_url != null)
      return authenticatedNetworkImage(
        _url!,
        fit: BoxFit.cover,
        cacheWidth: 222,
        errorBuilder: _error,
      );
    return FutureBuilder<Uint8List?>(
      key: ValueKey(widget.reference),
      future: _local,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return _error(context, Object(), null);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          cacheWidth: 222,
          errorBuilder: _error,
        );
      },
    );
  }

  Widget _error(BuildContext context, Object error, StackTrace? stack) =>
      Semantics(
        label: 'Evidence preview is temporarily unavailable',
        child: const Center(child: Icon(Icons.hide_image_outlined)),
      );
}
