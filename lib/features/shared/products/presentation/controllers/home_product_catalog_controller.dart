import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/data/home_product_snapshot_cache.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

enum HomeProductCatalogStatus { idle, loading, ready, error }

class HomeProductCatalogController extends ChangeNotifier {
  HomeProductCatalogController({
    HomeProductRepository? repository,
    this.pageSize = defaultPageSize,
  }) : _repository = repository ?? const HomeProductRepository();

  static const int defaultPageSize = 24;

  final HomeProductRepository _repository;
  final int pageSize;
  final List<HomeProduct> _products = <HomeProduct>[];
  late final List<HomeProduct> _productsView = UnmodifiableListView(_products);
  HomeProductCatalogStatus _status = HomeProductCatalogStatus.idle;
  Object? _error;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  var _loadGeneration = 0;
  var _isDisposed = false;

  List<HomeProduct> get products => _productsView;
  HomeProductCatalogStatus get status => _status;
  Object? get error => _error;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> load() async {
    if (_isDisposed) return;
    final generation = ++_loadGeneration;
    final owner = HomeProductSnapshotCache.authenticatedOwner();
    _status = HomeProductCatalogStatus.loading;
    _error = null;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListeners();
    unawaited(_restoreSnapshot(generation, owner));

    try {
      final page = await _repository.loadProductsPage(
        limit: pageSize,
        offset: 0,
      );
      if (!_isCurrent(generation, owner)) return;
      _products
        ..clear()
        ..addAll(page.products);
      _hasMore = page.hasMore;
      _status = HomeProductCatalogStatus.ready;
    } on Object catch (error) {
      if (!_isCurrent(generation, owner)) return;
      _error = error;
      _status = HomeProductCatalogStatus.error;
    }
    notifyListeners();
  }

  bool _isCurrent(int generation, String? owner) =>
      !_isDisposed &&
      generation == _loadGeneration &&
      owner == HomeProductSnapshotCache.authenticatedOwner();

  Future<void> _restoreSnapshot(int generation, String? owner) async {
    try {
      final page = await _repository.loadCachedProductsPage(limit: pageSize);
      if (page == null ||
          !_isCurrent(generation, owner) ||
          _status != HomeProductCatalogStatus.loading ||
          _products.isNotEmpty) {
        return;
      }
      _products.addAll(page.products);
      _hasMore = page.hasMore;
      notifyListeners();
    } on Object {
      // A snapshot is optional; the network request is already running.
    }
  }

  Future<void> loadMore() async {
    if (_isDisposed ||
        _status != HomeProductCatalogStatus.ready ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    final generation = _loadGeneration;
    final owner = HomeProductSnapshotCache.authenticatedOwner();
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.loadProductsPage(
        limit: pageSize,
        offset: _products.length,
      );
      if (!_isCurrent(generation, owner)) return;

      final existingIds = _products.map((p) => p.id).toSet();
      final fresh = page.products.where((p) => !existingIds.contains(p.id));
      _products.addAll(fresh);
      _hasMore = page.hasMore && page.products.isNotEmpty;
    } on Object catch (error) {
      if (!_isCurrent(generation, owner)) return;
      _error = error;
    } finally {
      if (_isCurrent(generation, owner)) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() => load();

  @override
  void dispose() {
    _isDisposed = true;
    _loadGeneration++;
    super.dispose();
  }
}
