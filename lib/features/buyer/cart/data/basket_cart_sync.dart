import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/buyer/cart/data/buyer_cart_repository.dart';
import 'package:agresell_app/features/buyer/cart/domain/basket_cart_item.dart';

class BasketCartSync {
  BasketCartSync({BuyerCartRepository? repository})
    : _repository = repository ?? const BuyerCartRepository();

  final BuyerCartRepository _repository;
  Future<void> _saveQueue = Future.value();

  void save(Iterable<BasketCartItem> items) {
    final snapshot = List<BasketCartItem>.of(items);
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _repository.save(snapshot);
      } on Object catch (error) {
        debugPrint('Cart sync failed: $error');
      }
    });
  }

  Future<void> flush() => _saveQueue;
}
