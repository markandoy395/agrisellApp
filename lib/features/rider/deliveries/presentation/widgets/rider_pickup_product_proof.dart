import 'package:flutter/material.dart';
import 'rider_pickup_proof_tile.dart';

/// Keep the captured evidence separate from the action that replaces it.
class RiderPickupProductProof extends StatelessWidget {
  const RiderPickupProductProof({
    required this.reference,
    required this.localImagePath,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });
  final String? reference;
  final String? localImagePath;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (reference != null) ...[
        Expanded(
          child: RiderPickupProofTile(
            label: 'product photo',
            icon: Icons.photo_outlined,
            reference: reference,
            isPhoto: true,
            localImagePath: localImagePath,
            onAdd: null,
            onRemove: onRemove,
          ),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: RiderPickupProofTile(
          label: 'product photo',
          icon: Icons.add_circle_rounded,
          onAdd: onAdd,
          highlight: true,
        ),
      ),
    ],
  );
}
