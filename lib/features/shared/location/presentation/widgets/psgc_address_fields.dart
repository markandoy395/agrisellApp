import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_matching.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/data/psgc_fallback_provinces.dart';
import 'package:agresell_app/features/shared/location/presentation/styles/psgc_address_styles.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/address_autocomplete_field.dart';

class PsgcAddressFields extends StatefulWidget {
  const PsgcAddressFields({
    required this.provinceController,
    required this.cityController,
    required this.barangayController,
    required this.onChanged,
    this.lookup,
    this.labelBuilder,
    this.decorationTheme,
    this.showSignupIcons = false,
    this.enabled = true,
    this.leadingIconBuilder,
    super.key,
  });

  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController barangayController;
  final VoidCallback onChanged;
  final PhilippineAddressLookup? lookup;
  final Widget Function(String label)? labelBuilder;
  final InputDecorationTheme? decorationTheme;
  final bool showSignupIcons;
  final bool enabled;
  final Widget Function(IconData icon)? leadingIconBuilder;

  @override
  State<PsgcAddressFields> createState() => _PsgcAddressFieldsState();
}

class _PsgcAddressFieldsState extends State<PsgcAddressFields> {
  late final PhilippineAddressLookup _lookup;
  final _cache = PsgcLocalityFilterCache();
  List<PsgcAddressOption> _barangays = const [];
  String _region = '';
  String? _loadedLocalityCode;

  @override
  void initState() {
    super.initState();
    _lookup = widget.lookup ?? PsgcAddressService.instance;
    if (widget.lookup == null) _cache.provinces = psgcFallbackProvinces;
    unawaited(_load(_lookup.provinces(), _setProvinces));
    unawaited(_load(_lookup.citiesMunicipalities(), _setLocalities));
  }

  void _setProvinces(List<PsgcAddressOption> values) {
    _cache.provinces = values;
    _provinceChanged(widget.provinceController.text);
  }

  void _setLocalities(List<PsgcAddressOption> values) {
    _cache.localities = values;
    _cityChanged(widget.cityController.text);
  }

  Future<void> _loadProvinceLocalities(PsgcAddressOption province) =>
      _load(_lookup.provinceCitiesMunicipalities(province.code), (values) {
        _cache.provinceLocalities[province.code] = values;
        _cityChanged(widget.cityController.text);
      });

  Future<void> _load(
    Future<List<PsgcAddressOption>> future,
    ValueChanged<List<PsgcAddressOption>> apply,
  ) async {
    final values = await future;
    if (mounted && values.isNotEmpty) setState(() => apply(values));
  }

  List<PsgcAddressOption> get _filteredLocalities =>
      _cache.resolve(widget.provinceController.text);

  void _provinceChanged(String value) {
    final match = exactPsgcOption(_cache.provinces, value);
    if (_cache.shouldRebuildForProvince(match, _region)) {
      setState(() {
        if (match != null) _region = match.region;
      });
    }
    if (match != null) unawaited(_loadProvinceLocalities(match));
    widget.onChanged();
  }

  void _pickProvince(PsgcAddressOption option) {
    widget.provinceController.text = option.name;
    widget.cityController.clear();
    widget.barangayController.clear();
    setState(() {
      _region = option.region;
      _loadedLocalityCode = null;
      _barangays = const [];
    });
    unawaited(_loadProvinceLocalities(option));
    widget.onChanged();
  }

  void _cityChanged(String value) {
    final match = exactPsgcOption(_filteredLocalities, value);
    if (match != null) unawaited(_pickLocality(match, clearBarangay: false));
    widget.onChanged();
  }

  Future<void> _pickLocality(
    PsgcAddressOption option, {
    bool clearBarangay = true,
  }) async {
    final ok = selectPsgcLocality(
      option: option,
      provinces: _cache.provinces,
      provinceController: widget.provinceController,
      cityController: widget.cityController,
      barangayController: widget.barangayController,
      clearBarangay: clearBarangay,
    );
    if (ok) setState(() => _region = option.region);
    widget.onChanged();
    if (!ok || (_loadedLocalityCode == option.code && _barangays.isNotEmpty)) {
      return;
    }
    _loadedLocalityCode = option.code;
    final values = await _lookup.barangays(option.code);
    if (mounted && _loadedLocalityCode == option.code) {
      setState(() => _barangays = values);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildField(
        label: 'Province',
        controller: widget.provinceController,
        options: _cache.provinces,
        onChanged: _provinceChanged,
        onSelected: _pickProvince,
      ),
      _buildField(
        label: 'City or municipality',
        controller: widget.cityController,
        options: _filteredLocalities,
        onChanged: _cityChanged,
        onSelected: _pickLocality,
      ),
      _buildField(
        label: 'Barangay',
        controller: widget.barangayController,
        options: _barangays,
        onSelected: (option) {
          widget.barangayController.text = option.name;
          widget.onChanged();
        },
      ),
      if (_region.isNotEmpty)
        Padding(
          padding: PsgcAddressStyles.regionPadding,
          child: Text('Region: $_region', style: PsgcAddressStyles.regionText),
        ),
    ],
  );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required List<PsgcAddressOption> options,
    required ValueChanged<PsgcAddressOption> onSelected,
    ValueChanged<String>? onChanged,
  }) => AddressAutocompleteField(
    label: label,
    enabled: widget.enabled,
    externalLabel: widget.labelBuilder?.call(label),
    decorationTheme: widget.decorationTheme,
    leadingIcon: PsgcAddressStyles.fieldIcon(
      label,
      widget.showSignupIcons,
      widget.leadingIconBuilder,
    ),
    controller: controller,
    options: options,
    onChanged: onChanged ?? (_) => widget.onChanged(),
    onSelected: onSelected,
  );
}
