import 'package:agresell_app/features/shared/chat/presentation/styles/chat_product_thumbnail_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

class ChatProductThumbnail extends StatelessWidget {
  const ChatProductThumbnail({
    required this.imageUrl,
    required this.size,
    required this.semanticLabel,
    this.borderRadius = 8,
    this.placeholderIcon = Icons.inventory_2_outlined,
    super.key,
  });

  final String? imageUrl;
  final double size;
  final double borderRadius;
  final String semanticLabel;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim();
    if (source != null && source.isNotEmpty) {
      return ProductThumbnail.square(
        imageUrl: source,
        size: size,
        borderRadius: borderRadius,
        semanticLabel: semanticLabel,
      );
    }

    return Semantics(
      image: true,
      label: '$semanticLabel image unavailable',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: ChatProductThumbnailStyles.containerDecoration(
            borderRadius,
          ),
          child: Icon(
            placeholderIcon,
            color: AgrisellColors.mutedText,
            size: 20,
          ),
        ),
      ),
    );
  }
}
