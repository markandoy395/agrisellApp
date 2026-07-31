import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/data/basket_cart_sync.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class BasketController extends ChangeNotifier {
  BasketController._();

  static final BasketController instance = BasketController._();

  final List<BasketCartItem> _items = <BasketCartItem>[];
  final _cartSync = BasketCartSync();
  late final List<BasketCartItem> _itemsView = UnmodifiableListView(_items);
  List<BasketCartItem> _selectedItems = const <BasketCartItem>[];
  var _pulse = 0;
  var _allSelected = false;
  var _totalQuantity = 0;
  var _selectedQuantity = 0;
  var _selectedTotal = 0.0;

  List<BasketCartItem> get items => _itemsView;

  List<BasketCartItem> get selectedItems => _selectedItems;

  int get pulse => _pulse;

  bool get hasItems => _items.isNotEmpty;

  bool get allSelected => _allSelected;

  int get totalQuantity => _totalQuantity;

  int get selectedQuantity => _selectedQuantity;

  double get selectedTotal => _selectedTotal;

  void addProduct(HomeProduct product, {int quantity = 1}) {
    if (!product.canOrder) {
      return;
    }

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
    if (index == -1) {
      return;
    }

    final item = _items[index];
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    _commitChange();
  }

  void decrementQuantity(String productId) {
    final index = _indexFor(productId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    if (item.quantity == 1) {
      return;
    }

    _items[index] = item.copyWith(quantity: item.quantity - 1);
    _commitChange();
  }

  BasketCartItem? removeProduct(String productId) {
    final index = _indexFor(productId);
    if (index == -1) {
      return null;
    }

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

    if (changed) {
      _commitChange();
    }
  }

  void setSelected(String productId, bool isSelected) {
    final index = _indexFor(productId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    if (item.isSelected == isSelected) {
      return;
    }

    _items[index] = item.copyWith(isSelected: isSelected);
    _commitChange();
  }

  void setAllSelected(bool isSelected) {
    if (_items.isEmpty) {
      return;
    }

    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      if (item.isSelected != isSelected) {
        _items[index] = item.copyWith(isSelected: isSelected);
        changed = true;
      }
    }

    if (changed) {
      _commitChange();
    }
  }

  void clear() {
    if (_items.isEmpty) {
      return;
    }

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

    if (_items.length != originalLength) {
      _commitChange();
    }
  }

  void _commitChange({bool synchronize = true}) {
    final selected = <BasketCartItem>[];
    var totalQuantity = 0;
    var selectedQuantity = 0;
    var selectedTotal = 0.0;
    var allSelected = _items.isNotEmpty;

    for (final item in _items) {
      totalQuantity += item.quantity;
      if (item.isSelected) {
        selected.add(item);
        selectedQuantity += item.quantity;
        selectedTotal += item.quantity * item.pricePerKg;
      } else {
        allSelected = false;
      }
    }

    _selectedItems = List<BasketCartItem>.unmodifiable(selected);
    _totalQuantity = totalQuantity;
    _selectedQuantity = selectedQuantity;
    _selectedTotal = selectedTotal;
    _allSelected = allSelected;
    notifyListeners();
    if (synchronize) _cartSync.save(_items);
  }

  int _indexFor(String productId) {
    return _items.indexWhere((item) => item.productId == productId);
  }
}
