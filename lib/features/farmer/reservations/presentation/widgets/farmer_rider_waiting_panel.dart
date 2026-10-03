import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_waiting_panel_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class FarmerRiderWaitingPanel extends StatelessWidget {
  const FarmerRiderWaitingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Waiting for an assigned rider. Choose an available local rider.',
      child: DecoratedBox(
        decoration: FarmerRiderWaitingPanelStyles.decoratedBoxDecoration,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DispatchIcon(),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting for an assigned rider',
                      style: SharedPresentationStyles.headingBodyExtraBold,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Choose an eligible rider below. The order is assigned only after the rider accepts your request.',
                      style: FarmerRiderWaitingPanelStyles.textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatchIcon extends StatelessWidget {
  const _DispatchIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: FarmerRiderWaitingPanelStyles.containerDecoration,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_shipping_outlined,
        size: 18,
        color: AgrisellColors.surface,
      ),
    );
  }
}
