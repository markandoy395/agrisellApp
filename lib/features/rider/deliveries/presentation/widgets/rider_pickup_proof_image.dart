import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import '../../data/pickup_proof_storage.dart';
import '../../data/rider_proof_image_reference.dart';
import '../styles/rider_pickup_design_styles.dart';

class RiderPickupProofImage extends StatefulWidget {
  const RiderPickupProofImage({
    required this.reference,
    this.localImagePath,
    this.resolveLocalPhoto,
    super.key,
  });
  final String reference;
  final String? localImagePath;
  final Future<File?> Function(String)? resolveLocalPhoto;
  @override
  State<RiderPickupProofImage> createState() => _RiderPickupProofImageState();
}

class _RiderPickupProofImageState extends State<RiderPickupProofImage> {
  Future<File?>? _local;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RiderPickupProofImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference ||
        oldWidget.localImagePath != widget.localImagePath ||
        oldWidget.resolveLocalPhoto != widget.resolveLocalPhoto)
      _load();
  }

  void _load() {
    _local =
        widget.localImagePath == null &&
            widget.reference.startsWith('local-secure://')
        ? (widget.resolveLocalPhoto ?? PickupProofStorage().resolveLocalPhoto)(
            widget.reference,
          )
        : null;
  }

  Widget _unavailable(BuildContext context, Object error, StackTrace? stack) =>
      Semantics(
        label: 'Photo preview unavailable',
        child: const Center(child: Icon(Icons.hide_image_outlined)),
      );
  Widget _file(File file) => Image.file(
    file,
    fit: BoxFit.cover,
    cacheWidth: 270,
    errorBuilder: _unavailable,
  );
  @override
  Widget build(BuildContext context) {
    final url = riderProofImageUrl(widget.reference);
    return ClipRRect(
      borderRadius: RiderPickupDesignStyles.radius,
      child: SizedBox(
        height: 64,
        width: 90,
        child: widget.localImagePath != null
            ? _file(File(widget.localImagePath!))
            : url != null
            ? authenticatedNetworkImage(
                url,
                fit: BoxFit.cover,
                cacheWidth: 270,
                errorBuilder: _unavailable,
              )
            : FutureBuilder<File?>(
                key: ValueKey(widget.reference),
                future: _local,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return snapshot.data != null
                      ? _file(snapshot.data!)
                      : _unavailable(context, Object(), null);
                },
              ),
      ),
    );
  }
}
