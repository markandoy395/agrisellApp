import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

class FarmerSignupField extends StatelessWidget {
  const FarmerSignupField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
    this.keyboardType,
    this.inputFormatters,
    this.password = false,
    this.leadingIcon,
    this.leadingIconBadge = false,
    this.leadingIconDivider = true,
    this.trailingIcon,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? error;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool password;
  final IconData? leadingIcon;
  final bool leadingIconBadge;
  final bool leadingIconDivider;
  final IconData? trailingIcon;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AuthTextField(
        hintText: label,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        showPasswordToggle: password,
        leadingIcon: leadingIcon,
        leadingIconBadge: leadingIconBadge,
        leadingIconDivider: leadingIconDivider,
        trailingIcon: trailingIcon,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        onChanged: onChanged,
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 3, left: 4),
          child: Text(
            error!,
            style: const TextStyle(
              color: AgrisellColors.statusRedText,
              fontSize: 12,
            ),
          ),
        ),
      const SizedBox(height: 8),
    ],
  );
}

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
        foregroundPainter: const _DashedBorderPainter(),
        child: Material(
          color: const Color(0xFFF1FAF5),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5F4EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF075239),
                          size: 32,
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -3,
                        child: Icon(
                          hasImage ? Icons.check_circle : Icons.add_circle,
                          color: AgrisellColors.authGreen,
                          size: 24,
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
                          style: const TextStyle(
                            color: Color(0xFF075239),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Upload a clear photo of yourself.',
                          style: TextStyle(
                            color: AgrisellColors.mutedText,
                            fontSize: 11,
                          ),
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
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8DEC8)
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
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
