import 'package:flutter/widgets.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

PsgcAddressOption? exactPsgcOption(
  List<PsgcAddressOption> values,
  String text,
) {
  final query = text.trim().toLowerCase();
  for (final option in values) {
    if (option.name.toLowerCase() == query) return option;
  }
  return null;
}

bool psgcBelongsToProvince(
  PsgcAddressOption locality,
  PsgcAddressOption province,
) {
  if (locality.province.toLowerCase() == province.name.toLowerCase()) {
    return true;
  }
  if (locality.provinceCode.isNotEmpty &&
      locality.provinceCode == province.code) {
    return true;
  }
  return locality.code.length >= 4 &&
      province.code.length >= 4 &&
      locality.code.substring(0, 4) == province.code.substring(0, 4);
}

bool selectPsgcLocality({
  required PsgcAddressOption option,
  required List<PsgcAddressOption> provinces,
  required TextEditingController provinceController,
  required TextEditingController cityController,
  required TextEditingController barangayController,
  required bool clearBarangay,
}) {
  final selected = exactPsgcOption(provinces, provinceController.text);
  if (selected != null && !psgcBelongsToProvince(option, selected)) {
    cityController.clear();
    barangayController.clear();
    return false;
  }
  if (provinceController.text.trim().isEmpty && option.province.isNotEmpty) {
    provinceController.text = option.province;
  }
  // Automatic matching must preserve the active keyboard composition/cursor.
  // Only an explicit selection may normalize the user's spelling or casing.
  if (clearBarangay && cityController.text != option.name) {
    cityController.text = option.name;
  }
  if (clearBarangay) barangayController.clear();
  return true;
}

List<PsgcAddressOption> filterPsgcLocalities(
  List<PsgcAddressOption> provinces,
  List<PsgcAddressOption> localities,
  Map<String, List<PsgcAddressOption>> provinceLocalities,
  String selectedProvinceText,
) {
  final selected = exactPsgcOption(provinces, selectedProvinceText);
  if (selected == null) return localities;
  final matches = localities
      .where((option) => psgcBelongsToProvince(option, selected))
      .toList(growable: false);
  if (matches.isNotEmpty) return matches;
  final byProvince = provinceLocalities[selected.code];
  return byProvince != null && byProvince.isNotEmpty ? byProvince : localities;
}

class PsgcLocalityFilterCache {
  List<PsgcAddressOption> provinces = const [];
  List<PsgcAddressOption> localities = const [];
  final Map<String, List<PsgcAddressOption>> provinceLocalities = {};
  String? _provinceCode;
  List<PsgcAddressOption> _localitiesRef = const [];
  List<PsgcAddressOption>? _provinceLocalitiesRef;
  List<PsgcAddressOption> _filtered = const [];

  bool shouldRebuildForProvince(PsgcAddressOption? match, String region) =>
      match?.code != _provinceCode || (match != null && match.region != region);

  List<PsgcAddressOption> resolve(String selectedProvinceText) {
    final selected = exactPsgcOption(provinces, selectedProvinceText);
    final code = selected?.code;
    final byProvince = code == null ? null : provinceLocalities[code];
    if (code == _provinceCode &&
        identical(localities, _localitiesRef) &&
        identical(byProvince, _provinceLocalitiesRef)) {
      return _filtered;
    }
    _provinceCode = code;
    _localitiesRef = localities;
    _provinceLocalitiesRef = byProvince;
    return _filtered = filterPsgcLocalities(
      provinces,
      localities,
      provinceLocalities,
      selectedProvinceText,
    );
  }
}
