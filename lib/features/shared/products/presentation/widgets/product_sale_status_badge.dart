import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class ProductSaleStatusBadge extends StatelessWidget {
  const ProductSaleStatusBadge({
    required this.product,
    this.showCountdown = false,
    this.iconOnly = false,
    super.key,
  });

  final HomeProduct product;
  final bool showCountdown;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensFor(product);
    if (iconOnly) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < tokens.length; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            _StatusIcon(token: tokens[index]),
          ],
        ],
      );
    }

    final countdown = showCountdown ? product.harvestCountdown : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [for (final token in tokens) _StatusChip(token: token)],
        ),
        if (countdown != null) ...[
          const SizedBox(height: 7),
          Text(
            countdown,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  List<_StatusToken> _tokensFor(HomeProduct product) {
    if (product.isSold || !product.isAvailable) {
      return [
        _StatusToken(
          label: product.buyerStatusLabel,
          icon: Icons.remove_shopping_cart_outlined,
          background: AgrisellColors.statusRedBackground,
          foreground: AgrisellColors.statusRedText,
        ),
      ];
    }
    return [
      _productionToken(product.productionStage),
      _saleToken(product.saleStatus),
    ];
  }

  _StatusToken _productionToken(ProductProductionStage stage) {
    return switch (stage) {
      ProductProductionStage.growing => const _StatusToken(
        label: 'Production: Growing',
        icon: Icons.eco_outlined,
        background: AgrisellColors.limeSoft,
        foreground: AgrisellColors.forestDark,
      ),
      ProductProductionStage.harvestingSoon => const _StatusToken(
        label: 'Production: Harvesting soon',
        icon: Icons.agriculture_outlined,
        background: AgrisellColors.statusOrangeBackground,
        foreground: AgrisellColors.statusOrangeText,
      ),
      ProductProductionStage.harvested => const _StatusToken(
        label: 'Production: Harvested',
        icon: Icons.inventory_2_outlined,
        background: AgrisellColors.forestSoft,
        foreground: AgrisellColors.forestDark,
      ),
    };
  }

  _StatusToken _saleToken(ProductSaleStatus status) {
    return switch (status) {
      ProductSaleStatus.readyNow => const _StatusToken(
        label: 'Selling: Available now',
        icon: Icons.local_shipping_outlined,
        background: AgrisellColors.forestSoft,
        foreground: AgrisellColors.forestDark,
      ),
      ProductSaleStatus.preOrder => const _StatusToken(
        label: 'Selling: Accepting pre-orders',
        icon: Icons.schedule_outlined,
        background: AgrisellColors.statusBlueBackground,
        foreground: AgrisellColors.statusBlueText,
      ),
      ProductSaleStatus.notAcceptingOrders => const _StatusToken(
        label: 'Selling: Not accepting orders',
        icon: Icons.block_outlined,
        background: AgrisellColors.statusRedBackground,
        foreground: AgrisellColors.statusRedText,
      ),
    };
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.token});

  final _StatusToken token;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: token.label,
      excludeSemantics: true,
      child: Tooltip(
        message: token.label,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: token.background,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(token.icon, color: token.foreground, size: 17),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.token});

  final _StatusToken token;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: token.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(token.icon, color: token.foreground, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              token.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: token.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusToken {
  const _StatusToken({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}
