import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_request_metadata.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_product_image.dart';

class RiderDetailProductCard extends StatelessWidget {
  const RiderDetailProductCard({required this.request, super.key});
  final DeliveryRequest request;
  @override
  Widget build(BuildContext context) => RiderDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RiderDetailProductImage(
              url: request.productImageUrl,
              productName: request.productName,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.productName,
                    style: RiderDeliveryReferenceStyles.title,
                  ),
                  if (request.productCategory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        request.productCategory,
                        style: RiderDeliveryReferenceStyles.body,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (request.quantityDescription.isNotEmpty)
                    Text(
                      'Quantity: ${request.quantityDescription}',
                      style: RiderDeliveryReferenceStyles.caption,
                    ),
                  if (request.totalWeightKg case final weight?)
                    Text(
                      'Total weight: $weight kg',
                      style: RiderDeliveryReferenceStyles.caption,
                    ),
                  if (request.packageDimensions case final dimensions?)
                    Text(
                      'Dimensions: ${dimensions.label}',
                      style: RiderDeliveryReferenceStyles.caption,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (request.handlingRequirements.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final requirement in request.handlingRequirements)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: RiderDeliveryReferenceStyles.tint(
                    AgrisellColors.statusBlueText,
                  ),
                  child: Text(
                    requirement.type.label,
                    style: RiderDeliveryReferenceStyles.strongCaption,
                  ),
                ),
            ],
          ),
        ],
        if (request.productDescription.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            request.productDescription,
            style: RiderDeliveryReferenceStyles.body,
          ),
        ],
      ],
    ),
  );
}

class RiderDetailProductImage extends StatelessWidget {
  const RiderDetailProductImage({required this.url, required this.productName});
  final String? url;
  final String productName;
  @override
  Widget build(BuildContext context) => RiderProductImage(
    source: url,
    productName: productName,
    dimension: 80,
    radius: const BorderRadius.all(Radius.circular(12)),
    unavailableLabel: '$productName image unavailable',
  );
}
