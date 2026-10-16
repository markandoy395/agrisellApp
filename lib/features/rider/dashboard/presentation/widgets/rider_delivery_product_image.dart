import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_product_image.dart';
import '../styles/rider_active_delivery_summary_styles.dart';

class RiderDeliveryProductImage extends StatelessWidget {
  const RiderDeliveryProductImage({this.path, super.key});
  final String? path;

  @override
  Widget build(BuildContext context) => RiderProductImage(
    source: path,
    productName: 'Delivery product',
    dimension: RiderActiveDeliverySummaryStyles.productImageDimension,
    radius: RiderActiveDeliverySummaryStyles.productImageRadius,
  );
}
