import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import '../styles/farmer_discounts_styles.dart';

class FarmerPromotionCard extends StatelessWidget {
  const FarmerPromotionCard({
    required this.discount,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final FarmerDiscount discount;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = FarmerDiscountsStyles.statusColor(discount.status);

    return Container(
      decoration: FarmerDiscountsStyles.promotionDecoration,
      child: Padding(
        padding: FarmerDiscountsStyles.promotionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: FarmerDiscountsStyles.discountBadgePadding,
                  decoration: FarmerDiscountsStyles.discountBadgeDecoration,
                  child: Text(
                    discount.discountLabel,
                    style: FarmerDiscountsStyles.discountBadgeText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: FarmerDiscountsStyles.statusBadgePadding,
                  decoration: FarmerDiscountsStyles.statusBadgeDecoration(
                    statusColor,
                  ),
                  child: Text(
                    discount.status.toUpperCase(),
                    style: FarmerDiscountsStyles.statusBadgeText(statusColor),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: discount.isEnabled,
                  activeTrackColor: AgrisellColors.authGreen,
                  onChanged: (val) => onToggle(val),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(discount.name, style: FarmerDiscountsStyles.promotionTitle),
            if (discount.hasCode) ...[
              const SizedBox(height: 4),
              _PromotionMetadataRow(
                icon: Icons.confirmation_number_outlined,
                text: 'Code: ${discount.promoCode}',
                textStyle: FarmerDiscountsStyles.codeText,
              ),
            ],
            const SizedBox(height: 4),
            _PromotionMetadataRow(
              icon: Icons.access_time_rounded,
              text: discount.formattedDates,
              textStyle: FarmerDiscountsStyles.datesText,
            ),
            if (discount.commodities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: discount.commodities
                    .map((c) {
                      return Chip(
                        label: Text(
                          c['commodity_name']?.toString() ?? 'Product',
                          style: FarmerDiscountsStyles.commodityText,
                        ),
                        backgroundColor: AgrisellColors.homeBackground,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    })
                    .toList(growable: false),
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: FarmerDiscountsStyles.editButton,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: FarmerDiscountsStyles.deleteButton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionMetadataRow extends StatelessWidget {
  const _PromotionMetadataRow({
    required this.icon,
    required this.text,
    required this.textStyle,
  });

  final IconData icon;
  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: AgrisellColors.mutedText),
      const SizedBox(width: 4),
      Text(text, style: textStyle),
    ],
  );
}
