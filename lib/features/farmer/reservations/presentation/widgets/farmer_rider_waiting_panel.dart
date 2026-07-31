import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerRiderWaitingPanel extends StatelessWidget {
  const FarmerRiderWaitingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Waiting for an assigned rider. Shipping starts after verified pickup.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.statusGreenBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AgrisellColors.authGreen.withValues(alpha: 0.28),
          ),
        ),
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
                      style: TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'The delivery request is live. Shipping starts automatically after the rider verifies pickup.',
                      style: TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
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
      decoration: const BoxDecoration(
        color: AgrisellColors.authGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_shipping_outlined,
        size: 18,
        color: AgrisellColors.surface,
      ),
    );
  }
}
