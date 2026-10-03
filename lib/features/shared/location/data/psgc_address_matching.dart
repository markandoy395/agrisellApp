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
