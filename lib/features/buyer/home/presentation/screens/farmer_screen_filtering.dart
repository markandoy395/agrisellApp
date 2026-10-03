part of 'farmer_screen.dart';

extension _FarmerScreenFiltering on _FarmerScreenState {
  List<FarmerProfile> _visibleFarmers(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty &&
        !_availableOnly &&
        !_followingOnly &&
        _selectedLocation == null &&
        _sort == _FarmerSort.recommended) {
      return _farmers;
    }
    final farmers = _farmers
        .where((farmer) {
          final matchesQuery =
              query.isEmpty || _searchText[farmer]!.contains(query);
          return matchesQuery &&
              (!_availableOnly || _availableProductCount(farmer) > 0) &&
              (!_followingOnly ||
                  _followController.stateFor(farmer).isFollowing) &&
              (_selectedLocation == null ||
                  farmer.location == _selectedLocation);
        })
        .toList(growable: false);
    switch (_sort) {
      case _FarmerSort.recommended:
        return farmers;
      case _FarmerSort.rating:
        farmers.sort((a, b) => b.rating.compareTo(a.rating));
      case _FarmerSort.availability:
        farmers.sort((a, b) {
          final result = _availableProductCount(
            b,
          ).compareTo(_availableProductCount(a));
          return result != 0 ? result : b.rating.compareTo(a.rating);
        });
    }
    return farmers;
  }

  int _availableProductCount(FarmerProfile farmer) =>
      _availableProductCounts[farmer] ?? 0;

  void _openFarmerShop(FarmerProfile farmer) => Navigator.of(
    context,
  ).pushNamed(AgrisellRoutes.farmerShop, arguments: farmer);

  void _openChat(FarmerProfile farmer) {
    unawaited(
      BuyerConversationLauncher.open(
        context,
        sellerName: farmer.name,
        farmId: farmer.farmId,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _query.value = '';
  }

  Future<void> _chooseSort() async {
    final choice = await showModalBottomSheet<_FarmerSort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort farmers by',
                style: SharedPresentationStyles.headingTitleExtraBold,
              ),
              const SizedBox(height: 8),
              for (final option in _FarmerSort.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_sortLabel(option)),
                  leading: Icon(
                    option == _sort
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AgrisellColors.authGreen,
                  ),
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null && mounted) _setSort(choice);
  }

  String _sortLabel(_FarmerSort sort) => switch (sort) {
    _FarmerSort.recommended => 'Recommended',
    _FarmerSort.rating => 'Highest rating',
    _FarmerSort.availability => 'Most available produce',
  };
}
