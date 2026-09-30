import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class FarmerSignupProgress extends StatelessWidget {
  const FarmerSignupProgress({required this.currentStep, super.key});

  final int currentStep;

  static const _labels = ['Account', 'Profile', 'Verification'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.maxWidth / 6;
        final labelHeight = MediaQuery.textScalerOf(context).scale(12) * 1.5;
        return SizedBox(
          height: 39 + labelHeight,
          child: Stack(
            children: [
              Positioned(
                left: inset,
                right: inset,
                top: 15,
                child: Row(
                  children: List.generate(
                    2,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        color: index < currentStep
                            ? AgrisellColors.authGreen
                            : AgrisellColors.borderLine,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(3, (index) {
                  final active = index <= currentStep;
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? AgrisellColors.authGreen
                                : AgrisellColors.deliveryGray,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AgrisellColors.surface,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AgrisellColors.surface,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _labels[index],
                          maxLines: 1,
                          style: TextStyle(
                            color: active
                                ? AgrisellColors.authGreen
                                : AgrisellColors.mutedText,
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
