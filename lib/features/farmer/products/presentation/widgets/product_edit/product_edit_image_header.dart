import 'package:agresell_app/features/farmer/products/presentation/styles/product_edit_image_header_styles.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/widgets/buttons/circular_header_icon_button.dart';

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
          decoration: ProductEditImageHeaderStyles.decoratedBoxDecoration,
        ),
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 0, 0),
              child: CircularHeaderIconButton(
                semanticLabel: 'Back to farmer screen',
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
                style: CircularHeaderIconButtonStyle.inkResponse(
                  dimension: 40,
                  backgroundColor: AgrisellColors.brandBlack.withValues(
                    alpha: 0.45,
                  ),
                  iconColor: AgrisellColors.surface,
                  iconSize: 24,
                  splashRadius: 24,
                ),
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
                decoration: ProductEditImageHeaderStyles.containerDecoration,
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
