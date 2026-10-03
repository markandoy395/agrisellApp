import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_active_delivery_summary_styles.dart';

class RiderDeliveryProductImage extends StatelessWidget {
  const RiderDeliveryProductImage({this.path, super.key});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final value = path;
    final image = value == null || value.isEmpty
        ? null
        : Uri.tryParse(value)?.hasScheme ?? false
        ? authenticatedNetworkImage(
            value,
            fit: BoxFit.cover,
            errorBuilder: _errorBuilder,
          )
        : Image.asset(value, fit: BoxFit.cover, errorBuilder: _errorBuilder);
    return ClipRRect(
      borderRadius: RiderActiveDeliverySummaryStyles.productImageRadius,
      child: SizedBox.square(
        dimension: RiderActiveDeliverySummaryStyles.productImageDimension,
        child: image ?? _errorBuilder(context, Object(), null),
      ),
    );
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stack) {
    return const ColoredBox(
      color: AgrisellColors.deliveryGray,
      child: Icon(Icons.inventory_2_outlined, color: AgrisellColors.mutedText),
    );
  }
}
