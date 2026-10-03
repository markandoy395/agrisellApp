import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_screen_states_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_checkout_bar.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_header.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_management_bar.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestions.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/empty_basket_state.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';

part 'basket_screen_states.dart';

const _basketUndoDuration = Duration(milliseconds: 1500);

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final _controller = BasketController.instance;

  void _openMessages() {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) =>
            const HomeScreen(initialNavIndex: HomeScreen.messageNavIndex),
      ),
    );
  }

  Future<void> _continueShopping() async {
    if (await Navigator.of(context).maybePop()) return;
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      agrisellMaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  void _removeItem(BasketCartItem item) {
    final removed = _controller.removeProduct(item.productId);
    if (removed == null) return;
    _showUndo(
      message: '${item.productName} removed from your basket.',
      items: [removed],
    );
  }

  void _removeSelected() {
    final removedItems = List<BasketCartItem>.of(_controller.selectedItems);
    if (removedItems.isEmpty) return;
    _controller.removeSelected();
    _showUndo(
      message:
          '${removedItems.length} ${removedItems.length == 1 ? 'product' : 'products'} removed.',
      items: removedItems,
    );
  }

  void _showUndo({
    required String message,
    required List<BasketCartItem> items,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..removeCurrentSnackBar()
      ..showAppSnackBar(
        SnackBar(
          content: Text(message),
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _controller.restoreItems(items),
          ),
        ),
        duration: _basketUndoDuration,
      );
  }

  @override
  Widget build(BuildContext context) {
    return BuyerResponsiveText(
      child: Scaffold(
        backgroundColor: AgrisellColors.homeBackground,
        bottomNavigationBar: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _controller.hasItems
              ? BasketCheckoutBar(controller: _controller)
              : const SizedBox.shrink(),
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final items = _controller.items;
            final excludedIds = items.map((item) => item.productId).toSet();
            return Column(
              children: [
                BasketHeader(
                  itemCount: items.length,
                  onMessagesTap: _openMessages,
                ),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyBasketContent(
                          excludedProductIds: excludedIds,
                          onContinueShopping: _continueShopping,
                        )
                      : _BasketContent(
                          controller: _controller,
                          excludedProductIds: excludedIds,
                          onRemoveItem: _removeItem,
                          onRemoveSelected: _removeSelected,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BasketContent extends StatelessWidget {
  const _BasketContent({
    required this.controller,
    required this.excludedProductIds,
    required this.onRemoveItem,
    required this.onRemoveSelected,
  });

  final BasketController controller;
  final Set<String> excludedProductIds;
  final ValueChanged<BasketCartItem> onRemoveItem;
  final VoidCallback onRemoveSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final items = controller.items;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        26,
      ),
      children: [
        BasketManagementBar(
          itemCount: items.length,
          selectedCount: controller.selectedItems.length,
          onRemoveSelected: onRemoveSelected,
        ),
        const SizedBox(height: 10),
        const _DeliveryNote(),
        const SizedBox(height: 12),
        for (var index = 0; index < items.length; index++) ...[
          BasketItem(
            key: ValueKey(items[index].productId),
            item: items[index],
            onSelectedChanged: (isSelected) {
              controller.setSelected(items[index].productId, isSelected);
            },
            onIncrement: () {
              controller.incrementQuantity(items[index].productId);
            },
            onDecrement: () {
              controller.decrementQuantity(items[index].productId);
            },
            onRemove: () => onRemoveItem(items[index]),
          ),
          if (index != items.length - 1) const SizedBox(height: 11),
        ],
        const SizedBox(height: 24),
        BasketSuggestions(excludedProductIds: excludedProductIds),
      ],
    );
  }
}
