import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';

class ProductAvailabilityList extends StatelessWidget {
  const ProductAvailabilityList({required this.products, super.key});

  final List<ProductAvailability> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final product in products)
          _ProductAvailabilityRow(product: product),
      ],
    );
  }
}

class _ProductAvailabilityRow extends StatelessWidget {
  const _ProductAvailabilityRow({required this.product});

  final ProductAvailability product;

  @override
  Widget build(BuildContext context) {
    final status = product.isAvailable ? 'Available' : 'Unavailable';
    final statusColor = product.isAvailable
        ? AgrisellColors.brandBlack
        : AgrisellColors.unavailableRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            flex: 44,
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmerTextStyles.productName(context),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(flex: 42, child: _DashedSeparator()),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmerTextStyles.productStatus(context, statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 12,
      child: CustomPaint(painter: _DashedSeparatorPainter()),
    );
  }
}

class _DashedSeparatorPainter extends CustomPainter {
  const _DashedSeparatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AgrisellColors.dividerLine
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dashWidth = 5.0;
    const dashGap = 4.0;
    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSeparatorPainter oldDelegate) => false;
}
