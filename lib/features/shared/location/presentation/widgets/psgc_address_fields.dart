import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/address_autocomplete_field.dart';

class PsgcAddressFields extends StatefulWidget {
  const PsgcAddressFields({
    required this.provinceController,
    required this.cityController,
    required this.barangayController,
    required this.onChanged,
    this.lookup,
    super.key,
  });

  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController barangayController;
  final VoidCallback onChanged;
  final PhilippineAddressLookup? lookup;

  @override
  State<PsgcAddressFields> createState() => _PsgcAddressFieldsState();
}

class _PsgcAddressFieldsState extends State<PsgcAddressFields> {
  late final PhilippineAddressLookup _lookup;
  List<PsgcAddressOption> _provinces = const [];
  List<PsgcAddressOption> _localities = const [];
  List<PsgcAddressOption> _barangays = const [];
  String _region = '';
  String? _loadedLocalityCode;

  @override
  void initState() {
    super.initState();
    _lookup = widget.lookup ?? PsgcAddressService.instance;
    unawaited(_loadTopLevels());
  }

  Future<void> _loadTopLevels() async {
    final results = await Future.wait([
      _lookup.provinces(),
      _lookup.citiesMunicipalities(),
    ]);
    if (!mounted) return;
    setState(() {
      _provinces = results[0];
      _localities = results[1];
    });
    _provinceChanged(widget.provinceController.text);
    _cityChanged(widget.cityController.text);
  }

  List<PsgcAddressOption> get _filteredLocalities {
    final province = widget.provinceController.text.trim().toLowerCase();
    if (province.isEmpty) return _localities;
    return _localities
        .where((option) => option.province.toLowerCase() == province)
        .toList(growable: false);
  }

  void _provinceChanged(String value) {
    final match = _exact(_provinces, value);
    if (match != null && match.region != _region) {
      setState(() => _region = match.region);
    }
    widget.onChanged();
  }

  void _cityChanged(String value) {
    final match = _exact(_filteredLocalities, value);
    if (match != null) unawaited(_selectLocality(match, clearBarangay: false));
    widget.onChanged();
  }

  Future<void> _selectLocality(
    PsgcAddressOption option, {
    bool clearBarangay = true,
  }) async {
    final selectedProvince = widget.provinceController.text.trim();
    if (selectedProvince.isNotEmpty &&
        option.province.isNotEmpty &&
        selectedProvince.toLowerCase() != option.province.toLowerCase()) {
      widget.cityController.clear();
      widget.barangayController.clear();
      widget.onChanged();
      return;
    }
    if (selectedProvince.isEmpty && option.province.isNotEmpty) {
      widget.provinceController.text = option.province;
    }
    if (clearBarangay) widget.barangayController.clear();
    setState(() => _region = option.region);
    widget.onChanged();
    if (_loadedLocalityCode == option.code) return;
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
      AddressAutocompleteField(
        label: 'Province',
        controller: widget.provinceController,
        options: _provinces,
        onChanged: _provinceChanged,
        onSelected: (option) {
          widget.cityController.clear();
          widget.barangayController.clear();
          setState(() {
            _region = option.region;
            _barangays = const [];
          });
          widget.onChanged();
        },
      ),
      AddressAutocompleteField(
        label: 'City or municipality',
        controller: widget.cityController,
        options: _filteredLocalities,
        onChanged: _cityChanged,
        onSelected: _selectLocality,
      ),
      AddressAutocompleteField(
        label: 'Barangay',
        controller: widget.barangayController,
        options: _barangays,
        onChanged: (_) => widget.onChanged(),
        onSelected: (_) => widget.onChanged(),
      ),
      if (_region.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            'Region: $_region',
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ),
    ],
  );
}

PsgcAddressOption? _exact(List<PsgcAddressOption> values, String text) {
  final query = text.trim().toLowerCase();
  for (final option in values) {
    if (option.name.toLowerCase() == query) return option;
  }
  return null;
}
