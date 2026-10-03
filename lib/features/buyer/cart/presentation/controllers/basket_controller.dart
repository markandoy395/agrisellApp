import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/data/basket_cart_sync.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_totals.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class BasketController extends ChangeNotifier {
  BasketController._();

  static final BasketController instance = BasketController._();

  final List<BasketCartItem> _items = <BasketCartItem>[];
  final _cartSync = BasketCartSync();
  late final List<BasketCartItem> _itemsView = UnmodifiableListView(_items);
  BasketTotals _totals = BasketTotals.empty;
  var _pulse = 0;

  List<BasketCartItem> get items => _itemsView;
  List<BasketCartItem> get selectedItems => _totals.selectedItems;
  int get pulse => _pulse;
  bool get hasItems => _items.isNotEmpty;
  bool get allSelected => _totals.allSelected;
  int get totalQuantity => _totals.totalQuantity;
  int get selectedQuantity => _totals.selectedQuantity;
  double get selectedTotal => _totals.selectedTotal;

  void addProduct(HomeProduct product, {int quantity = 1}) {
    if (!product.canOrder) return;

    final safeQuantity = quantity < 1 ? 1 : quantity;
    final index = _items.indexWhere((item) => item.productId == product.id);

    if (index == -1) {
      _items.add(BasketCartItem.fromProduct(product, quantity: safeQuantity));
    } else {
      final item = _items[index];
      _items[index] = item.copyWith(
        quantity: item.quantity + safeQuantity,
        isSelected: true,
      );
    }

    _pulse++;
    _commitChange();
  }

  void incrementQuantity(String productId) {
    final index = _indexFor(productId);
    if (index == -1) return;

    final item = _items[index];
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    _commitChange();
  }

  void decrementQuantity(String productId) {
    final index = _indexFor(productId);
    if (index == -1) return;

    final item = _items[index];
    if (item.quantity == 1) return;

    _items[index] = item.copyWith(quantity: item.quantity - 1);
    _commitChange();
  }

  BasketCartItem? removeProduct(String productId) {
    final index = _indexFor(productId);
    if (index == -1) return null;

    final removedItem = _items.removeAt(index);
    _commitChange();
    return removedItem;
  }

  void restoreItems(Iterable<BasketCartItem> items) {
    var changed = false;
    for (final item in items) {
      if (_indexFor(item.productId) == -1) {
        _items.add(item);
        changed = true;
      }
    }

    if (changed) _commitChange();
  }

  void setSelected(String productId, bool isSelected) {
    final index = _indexFor(productId);
    if (index == -1) return;

    final item = _items[index];
    if (item.isSelected == isSelected) return;

    _items[index] = item.copyWith(isSelected: isSelected);
    _commitChange();
  }

  void setAllSelected(bool isSelected) {
    if (_items.isEmpty) return;

    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      if (item.isSelected != isSelected) {
        _items[index] = item.copyWith(isSelected: isSelected);
        changed = true;
      }
    }

    if (changed) _commitChange();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _commitChange();
  }

  void unload() {
    if (_items.isEmpty) return;
    _items.clear();
    _commitChange(synchronize: false);
  }

  Future<void> flush() => _cartSync.flush();

  void removeSelected() {
    final originalLength = _items.length;
    _items.removeWhere((item) => item.isSelected);

    if (_items.length != originalLength) _commitChange();
  }

  bool reconcileAvailableQuantities(Map<String, int> quantities) {
    final changed = BasketItemOperations.reconcileQuantities(_items, quantities);
    if (changed) _commitChange();
    return changed;
  }

  void _commitChange({bool synchronize = true}) {
    _totals = BasketTotals.compute(_items);
    notifyListeners();
    if (synchronize) _cartSync.save(_items);
  }

  int _indexFor(String productId) =>
      _items.indexWhere((item) => item.productId == productId);
}
