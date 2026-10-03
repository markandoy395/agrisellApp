import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_matching.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
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
    final selected = exactPsgcOption(_provinces, widget.provinceController.text);
    if (selected == null) return _localities;
    final matches = _localities
        .where((option) => psgcBelongsToProvince(option, selected))
        .toList(growable: false);
    return matches.isEmpty ? _localities : matches;
  }

  void _provinceChanged(String value) {
    final match = exactPsgcOption(_provinces, value);
    if (match != null && match.region != _region) {
      setState(() => _region = match.region);
    }
    widget.onChanged();
  }

  void _cityChanged(String value) {
    final match = exactPsgcOption(_filteredLocalities, value);
    if (match != null) unawaited(_selectLocality(match, clearBarangay: false));
    widget.onChanged();
  }

  Future<void> _selectLocality(
    PsgcAddressOption option, {
    bool clearBarangay = true,
  }) async {
    final selectedProvince = widget.provinceController.text.trim();
    final province = exactPsgcOption(_provinces, selectedProvince);
    if (province != null && !psgcBelongsToProvince(option, province)) {
      widget.cityController.clear();
      widget.barangayController.clear();
      widget.onChanged();
      return;
    }
    if (selectedProvince.isEmpty && option.province.isNotEmpty) {
      widget.provinceController.text = option.province;
    }
    widget.cityController.text = option.name;
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
        enabled: widget.enabled,
        externalLabel: widget.labelBuilder?.call('Province'),
        decorationTheme: widget.decorationTheme,
        leadingIcon: widget.showSignupIcons
            ? _signupIcon(Icons.map_outlined)
            : null,
        controller: widget.provinceController,
        options: _provinces,
        onChanged: _provinceChanged,
        onSelected: (option) {
          widget.provinceController.text = option.name;
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
        key: ValueKey(
          'city:${widget.provinceController.text.trim().toLowerCase()}',
        ),
        label: 'City or municipality',
        enabled: widget.enabled,
        externalLabel: widget.labelBuilder?.call('City or municipality'),
        decorationTheme: widget.decorationTheme,
        leadingIcon: widget.showSignupIcons
            ? _signupIcon(Icons.location_city_outlined)
            : null,
        controller: widget.cityController,
        options: _filteredLocalities,
        onChanged: _cityChanged,
        onSelected: _selectLocality,
      ),
      AddressAutocompleteField(
        key: ValueKey('barangay:${_loadedLocalityCode ?? ''}'),
        label: 'Barangay',
        enabled: widget.enabled,
        externalLabel: widget.labelBuilder?.call('Barangay'),
        decorationTheme: widget.decorationTheme,
        leadingIcon: widget.showSignupIcons
            ? _signupIcon(Icons.home_outlined)
            : null,
        controller: widget.barangayController,
        options: _barangays,
        onChanged: (_) => widget.onChanged(),
        onSelected: (option) {
          widget.barangayController.text = option.name;
          widget.onChanged();
        },
      ),
      if (_region.isNotEmpty)
        Padding(
          padding: PsgcAddressStyles.regionPadding,
          child: Text(
            'Region: $_region',
            style: PsgcAddressStyles.regionText,
          ),
        ),
    ],
  );

  Widget _signupIcon(IconData icon) =>
      widget.leadingIconBuilder?.call(icon) ??
      Icon(icon, color: PsgcAddressStyles.iconColor);
}
