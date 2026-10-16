import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_pickup_design_styles.dart';
import 'rider_pickup_proof_image.dart';

class RiderPickupProofTile extends StatelessWidget {
  const RiderPickupProofTile({
    required this.label,
    required this.icon,
    required this.onAdd,
    this.reference,
    this.localImagePath,
    this.onRemove,
    this.highlight = false,
    this.isPhoto = false,
    super.key,
  });
  final String label;
  final IconData icon;
  final String? reference;
  final String? localImagePath;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool highlight;
  final bool isPhoto;
  @override
  Widget build(BuildContext context) {
    final saved = reference != null;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: RiderPickupDesignStyles.proof(saved || highlight),
            onPressed: onAdd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (saved && isPhoto)
                  RiderPickupProofImage(
                    reference: reference!,
                    localImagePath: localImagePath,
                  )
                else
                  Icon(saved ? Icons.check_circle_rounded : icon, size: 28),
                const SizedBox(height: 8),
                Text(
                  saved ? '$label saved' : 'Add $label proof',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (saved && onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove $label from pickup',
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AgrisellColors.mutedText,
              ),
            ),
          ),
      ],
    );
  }
}
