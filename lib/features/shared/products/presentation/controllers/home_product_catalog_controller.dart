import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

enum HomeProductCatalogStatus { idle, loading, ready, error }

class HomeProductCatalogController extends ChangeNotifier {
  HomeProductCatalogController({HomeProductRepository? repository})
    : _repository = repository ?? const HomeProductRepository();

  final HomeProductRepository _repository;
  final List<HomeProduct> _products = <HomeProduct>[];
  late final List<HomeProduct> _productsView = UnmodifiableListView(_products);
  HomeProductCatalogStatus _status = HomeProductCatalogStatus.idle;
  Object? _error;
  var _loadGeneration = 0;
  var _isDisposed = false;

  List<HomeProduct> get products => _productsView;
  HomeProductCatalogStatus get status => _status;
  Object? get error => _error;

  Future<void> load() async {
    if (_isDisposed) return;
    final generation = ++_loadGeneration;
    _status = HomeProductCatalogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final products = await _repository.loadProducts();
      if (_isDisposed || generation != _loadGeneration) return;
      _products
        ..clear()
        ..addAll(products);
      _status = HomeProductCatalogStatus.ready;
    } on Object catch (error) {
      if (_isDisposed || generation != _loadGeneration) return;
      _products.clear();
      _error = error;
      _status = HomeProductCatalogStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _loadGeneration++;
    super.dispose();
  }
}
