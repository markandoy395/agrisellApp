import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';

enum HomeProductSort {
  recommended('Recommended'),
  priceLowToHigh('Price: low to high'),
  priceHighToLow('Price: high to low'),
  newestHarvest('Newest harvest');

  const HomeProductSort(this.label);

  final String label;
}

class HomeProductBrowseController extends ChangeNotifier {
  String _query = '';
  String _selectedCategory = 'All';
  HomeProductSort _sort = HomeProductSort.recommended;
  bool _savedOnly = false;
  final Set<String> _savedProductIds = {};
  final Expando<_HomeProductMetadata> _metadata =
      Expando<_HomeProductMetadata>();

  String get query => _query;
  String get selectedCategory => _selectedCategory;
  HomeProductSort get sort => _sort;
  bool get availableOnly => true;
  bool get savedOnly => _savedOnly;
  int get savedCount => _savedProductIds.length;

  int get activeFilterCount {
    return (_selectedCategory == 'All' ? 0 : 1) + (_savedOnly ? 1 : 0);
  }

  bool get hasActiveDiscoveryOptions {
    return _query.isNotEmpty ||
        activeFilterCount > 0 ||
        _sort != HomeProductSort.recommended;
  }

  bool isSaved(String productId) => _savedProductIds.contains(productId);

  void updateQuery(String value) {
    final nextQuery = value.trim().toLowerCase();
    if (_query == nextQuery) return;
    _query = nextQuery;
    notifyListeners();
  }

  void selectCategory(String value) {
    final normalized = value.replaceAll('\n', ' ').trim();
    if (_selectedCategory == normalized) return;
    _selectedCategory = normalized;
    notifyListeners();
  }

  void setSort(HomeProductSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  void setAvailableOnly(bool value) {
    // Buyer listings are always limited to orderable products.
  }

  void setSavedOnly(bool value) {
    if (_savedOnly == value) return;
    _savedOnly = value;
    notifyListeners();
  }

  void toggleSaved(String productId) {
    if (!_savedProductIds.remove(productId)) {
      _savedProductIds.add(productId);
    }
    notifyListeners();
  }

  void resetDiscoveryOptions() {
    if (!hasActiveDiscoveryOptions) return;

    _query = '';
    _selectedCategory = 'All';
    _sort = HomeProductSort.recommended;
    _savedOnly = false;
    notifyListeners();
  }

  List<HomeProduct> visibleProducts(List<HomeProduct> products) {
    final visible = products
        .where((product) {
          final metadata = _metadataFor(product);
          final matchesSearch =
              _query.isEmpty || metadata.searchText.contains(_query);
          final matchesCategory =
              _selectedCategory == 'All' ||
              product.category == _selectedCategory;
          // The buyer marketplace never exposes products that cannot be
          // ordered. The repository applies the same rule server-side; this
          // remains as defense in depth for cached and injected catalogs.
          final matchesAvailability = product.canOrder;
          final matchesSaved = !_savedOnly || isSaved(product.id);

          return matchesSearch &&
              matchesCategory &&
              matchesAvailability &&
              matchesSaved;
        })
        .toList(growable: false);

    return switch (_sort) {
      HomeProductSort.recommended => visible,
      HomeProductSort.priceLowToHigh =>
        visible..sort(
          (a, b) => _metadataFor(a).price.compareTo(_metadataFor(b).price),
        ),
      HomeProductSort.priceHighToLow =>
        visible..sort(
          (a, b) => _metadataFor(b).price.compareTo(_metadataFor(a).price),
        ),
      HomeProductSort.newestHarvest =>
        visible..sort(
          (a, b) => _metadataFor(
            b,
          ).harvestDate.compareTo(_metadataFor(a).harvestDate),
        ),
    };
  }

  _HomeProductMetadata _metadataFor(HomeProduct product) {
    return _metadata[product] ??= _HomeProductMetadata(
      searchText:
          '${product.name}\u0000${product.category}\u0000${product.sellerName}\u0000'
                  '${product.sellerLocation}'
              .toLowerCase(),
      price: _priceOf(product.price),
      harvestDate: _dateOf(product.harvestDate),
    );
  }

  double _priceOf(String price) {
    final normalized = price.replaceAll(',', '');
    final match = _numberPattern.firstMatch(normalized);
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  DateTime _dateOf(String harvestDate) {
    final parts = harvestDate.replaceAll(',', '').split(' ');
    if (parts.length != 3) return _epoch;
    final month = _months[parts[0]] ?? 1;
    final day = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 1970;
    return DateTime(year, month, day);
  }
}

class _HomeProductMetadata {
  const _HomeProductMetadata({
    required this.searchText,
    required this.price,
    required this.harvestDate,
  });

  final String searchText;
  final double price;
  final DateTime harvestDate;
}

final _numberPattern = RegExp(r'\d+(?:\.\d+)?');
final _epoch = DateTime(1970);

const _months = {
  'January': 1,
  'February': 2,
  'March': 3,
  'April': 4,
  'May': 5,
  'June': 6,
  'July': 7,
  'August': 8,
  'September': 9,
  'October': 10,
  'November': 11,
  'December': 12,
};
