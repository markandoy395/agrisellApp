import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';

class ProductEditImageHeader extends StatelessWidget {
  const ProductEditImageHeader({
    required this.imageAsset,
    required this.imageBytes,
    required this.imageUrl,
    required this.onBack,
    required this.onCameraTap,
    super.key,
  });

  final String? imageAsset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback onBack;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ResponsiveAssetImage(
          asset: imageAsset,
          imageBytes: imageBytes,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          semanticLabel: 'Product photo',
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 0, 0),
              child: _RoundIconButton(
                semanticLabel: 'Back to farmer screen',
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
            ),
          ),
        ),
        Center(
          child: Semantics(
            button: true,
            label: 'Replace product photo',
            child: InkResponse(
              onTap: onCameraTap,
              radius: 58,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: AgrisellColors.surface.withValues(alpha: 0.33),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: AgrisellColors.surface,
                  size: 58,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AgrisellColors.surface, size: 24),
        ),
      ),
    );
  }
}
