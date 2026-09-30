import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_bottom_border.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_product_thumbnail.dart';

class FarmerMessageProductPreview extends StatelessWidget {
  const FarmerMessageProductPreview({required this.thread, super.key});

  final MarketplaceConversation thread;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            child: Row(
              children: [
                ChatProductThumbnail(
                  imageUrl: thread.productImageUrl,
                  size: 58,
                  borderRadius: 8,
                  semanticLabel: thread.productName ?? thread.farmName,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.productName ?? thread.farmName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 14,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _quantityAndPrice(thread),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.brandBlack,
                          fontSize: 12,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _StatusChip(label: thread.orderStatusLabel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const MessageBottomBorder(color: AgrisellColors.authGreen),
        ],
      ),
    );
  }

  String _quantityAndPrice(MarketplaceConversation value) {
    final quantityText = value.quantity == null
        ? ''
        : '${_number(value.quantity!)} ${value.unitType ?? 'unit'}';
    final priceText = value.unitPrice == null
        ? ''
        : '₱${_number(value.unitPrice!)} each';
    final details = [
      quantityText,
      priceText,
    ].where((item) => item.isNotEmpty).join(' • ');
    return details.isEmpty ? value.farmName : details;
  }

  String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AgrisellColors.statusGreenBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
