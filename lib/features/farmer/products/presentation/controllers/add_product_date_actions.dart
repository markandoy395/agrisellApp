part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

extension _AddProductDateActions on _AddProductScreenState {
  bool get _requiresExpectedDate => _dateWindow.isRequired;

  AvailabilityDateWindow get _dateWindow =>
      ProductAvailabilityDateRules.windowFor(
        productionStage: _productionStage,
        sellingOption: _saleStatus,
      );

  String get _displayDate {
    final date = _expectedDate;
    if (_requiresExpectedDate && date != null) {
      return '${_months[date.month - 1]} ${date.day}, ${date.year}';
    }
    final today = ProductAvailabilityDateRules.philippineToday();
    return '${_months[today.month - 1]} ${today.day}, ${today.year}';
  }

  void _normalizeExpectedDate() {
    final date = _expectedDate;
    if (date != null && !_dateWindow.includes(date)) _expectedDate = null;
  }

  Future<void> _pickExpectedDate() async {
    final window = _dateWindow;
    final current = _expectedDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: current != null && window.includes(current)
          ? current
          : window.firstDate,
      firstDate: window.firstDate,
      lastDate: window.lastDate,
      currentDate: ProductAvailabilityDateRules.philippineToday(),
      helpText: 'Expected availability date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _expectedDate = selected;
      _lotHarvestedAt = selected;
      _errors.remove(AddProductField.harvestDate);
      _errors.remove(AddProductField.lotHarvestDate);
    });
  }

  Future<void> _pickLotHarvestDate() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final latest = _productionStage == ProductProductionStage.harvested
        ? today
        : _dateWindow.lastDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: _lotHarvestedAt ?? today,
      firstDate: DateTime(today.year - 2),
      lastDate: latest,
      currentDate: today,
      helpText: 'Harvest or production date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _lotHarvestedAt = selected;
      if (_marketableUntil != null && _marketableUntil!.isBefore(selected)) {
        _marketableUntil = null;
      }
      _errors.remove(AddProductField.lotHarvestDate);
    });
  }

  Future<void> _pickMarketableUntil() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final harvest = _lotHarvestedAt;
    final firstDate = harvest != null && harvest.isAfter(today)
        ? harvest
        : today;
    final selected = await showDatePicker(
      context: context,
      initialDate: _marketableUntil ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 10, firstDate.month, firstDate.day),
      currentDate: today,
      helpText: _inventoryDateType == ProductInventoryDateType.packagedFood
          ? 'Printed expiration date'
          : 'Final selling date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _marketableUntil = selected;
      _errors.remove(AddProductField.marketableUntil);
    });
  }
}
