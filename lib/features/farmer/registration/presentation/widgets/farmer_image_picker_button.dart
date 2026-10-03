import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_image_picker_button_styles.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_field_styles.dart';

class FarmerImagePickerButton extends StatelessWidget {
  const FarmerImagePickerButton({
    required this.label,
    required this.hasImage,
    required this.onPressed,
    this.profileStyle = false,
    super.key,
  });

  final String label;
  final bool hasImage;
  final VoidCallback onPressed;
  final bool profileStyle;

  @override
  Widget build(BuildContext context) {
    if (profileStyle) {
      return CustomPaint(
        foregroundPainter: const FarmerDashedBorderPainter(),
        child: Material(
          color: FarmerSignupFieldStyles.pickerCardColor,
          borderRadius: FarmerSignupFieldStyles.pickerBorderRadius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: FarmerSignupFieldStyles.pickerBorderRadius,
            child: Padding(
              padding: FarmerSignupFieldStyles.pickerPadding,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: FarmerSignupFieldStyles.pickerCircleSize,
                        height: FarmerSignupFieldStyles.pickerCircleSize,
                        decoration:
                            FarmerImagePickerButtonStyles.containerDecoration,
                        child: const Icon(
                          Icons.image_outlined,
                          color: FarmerSignupFieldStyles.pickerDarkGreen,
                          size: FarmerSignupFieldStyles.pickerIconSize,
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -3,
                        child: Icon(
                          hasImage ? Icons.check_circle : Icons.add_circle,
                          color: AgrisellColors.authGreen,
                          size: FarmerSignupFieldStyles.pickerBadgeSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasImage ? 'Profile image selected' : label,
                          style: FarmerSignupFieldStyles.pickerTitleStyle,
                        ),
                        const Text(
                          'Upload a clear photo of yourself.',
                          style: FarmerSignupFieldStyles.pickerSubtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        hasImage
            ? Icons.check_circle_outline
            : Icons.add_photo_alternate_outlined,
      ),
      label: Text(hasImage ? '$label selected' : label),
      style: FarmerSignupFieldStyles.pickerButtonStyle,
    );
  }
}

class FarmerDashedBorderPainter extends CustomPainter {
  const FarmerDashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FarmerSignupFieldStyles.pickerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 14) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 8, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FarmerDashedBorderPainter oldDelegate) => false;
}
