import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import '../../controllers/home_product_browse_controller.dart';
import '../../styles/buyer_catalog_styles.dart';
import 'buyer_catalog_card.dart';
import 'buyer_catalog_actions.dart';

class BuyerCatalogGrid extends StatelessWidget {
  const BuyerCatalogGrid({
    required this.products,
    required this.onProductTap,
    this.browseController,
    this.sale = false,
    super.key,
  });
  final List<HomeProduct> products;
  final ValueChanged<HomeProduct> onProductTap;
  final HomeProductBrowseController? browseController;
  final bool sale;

  SliverGridDelegate _delegate(BuildContext context, double width) {
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    const columns = BuyerCatalogStyles.columns;
    final cardWidth = (width - (columns - 1) * 10) / columns;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: 10,
      mainAxisSpacing: 14,
      mainAxisExtent: BuyerCatalogStyles.cardHeight(
        cardWidth,
        scale,
        sale: sale,
      ),
    );
  }

  Widget _card(BuildContext context, int index) {
    final product = products[index];
    return BuyerCatalogCard(
      key: ValueKey('catalog-product-${product.id}'),
      product: product,
      sale: sale && product.hasSale,
      saved: browseController?.isSaved(product.id) ?? false,
      onSave: browseController == null
          ? null
          : () => browseController!.toggleSaved(product.id),
      onTap: () => onProductTap(product),
      onAdd: () => addCatalogProduct(context, product),
    );
  }

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) => SliverGrid.builder(
      itemCount: products.length,
      // Cards have no editable state to retain after leaving the viewport.
      addAutomaticKeepAlives: false,
      gridDelegate: _delegate(context, constraints.crossAxisExtent),
      itemBuilder: _card,
    ),
  );
}
