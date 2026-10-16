import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/pickup_confirmation.dart';
import '../styles/rider_pickup_design_styles.dart';

IconData pickupProblemIcon(PickupProblemKind kind) => switch (kind) {
  PickupProblemKind.productNotReady => Icons.inventory_2_outlined,
  PickupProblemKind.wrongProduct => Icons.category_outlined,
  PickupProblemKind.incorrectQuantity => Icons.grid_view_outlined,
  PickupProblemKind.incorrectWeight => Icons.scale_outlined,
  PickupProblemKind.damagedProduct => Icons.warning_amber_rounded,
  PickupProblemKind.poorPackaging => Icons.inventory_outlined,
  PickupProblemKind.exceedsVehicleCapacity => Icons.local_shipping_outlined,
  PickupProblemKind.farmerUnavailable => Icons.person_outline_rounded,
  PickupProblemKind.confirmationProblem => Icons.description_outlined,
  PickupProblemKind.other => Icons.more_horiz_rounded,
};

class RiderPickupProblemOptions extends StatelessWidget {
  const RiderPickupProblemOptions({
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final PickupProblemKind selected;
  final ValueChanged<PickupProblemKind> onChanged;
  @override
  Widget build(BuildContext context) => RadioGroup<PickupProblemKind>(
    groupValue: selected,
    onChanged: (kind) {
      if (kind != null) onChanged(kind);
    },
    child: Column(
      children: [
        for (final kind in PickupProblemKind.values)
          Container(
            decoration: kind == selected
                ? RiderPickupDesignStyles.tint(AgrisellColors.authGreen)
                : null,
            child: Material(
              type: MaterialType.transparency,
              child: RadioListTile<PickupProblemKind>(
                value: kind,
                activeColor: AgrisellColors.authGreen,
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Icon(
                      pickupProblemIcon(kind),
                      color: AgrisellColors.headingGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        kind.label,
                        style: RiderPickupDesignStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
