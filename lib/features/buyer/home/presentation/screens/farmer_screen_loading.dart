part of 'farmer_screen.dart';

extension _FarmerScreenLoading on _FarmerScreenState {
  Future<void> _loadFarmers() async {
    _updateUi(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final farmers = await widget.farmerDirectoryRepository.loadFarmers();
      if (!mounted) return;
      _followController.seed(farmers);
      _updateUi(() {
        _farmers = farmers;
        _rebuildFarmerSearchData();
        _isLoading = false;
      });
    } on Object {
      if (mounted) {
        _updateUi(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _rebuildFarmerSearchData() {
    _locations = List<String>.unmodifiable({
      for (final farmer in _farmers) farmer.location,
    });
    _availableProductCounts = {
      for (final farmer in _farmers)
        farmer: farmer.products.where((product) => product.isAvailable).length,
    };
    _searchText = {
      for (final farmer in _farmers)
        farmer:
            '${farmer.name}\u0000${farmer.location}\u0000'
                    '${farmer.products.map((product) => product.name).join('\u0000')}'
                .toLowerCase(),
    };
  }
}
