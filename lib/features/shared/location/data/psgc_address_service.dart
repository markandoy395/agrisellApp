import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PsgcAddressOption {
  const PsgcAddressOption({
    required this.code,
    required this.name,
    this.province = '',
    this.provinceCode = '',
    this.region = '',
  });

  final String code;
  final String name;
  final String province;
  final String provinceCode;
  final String region;
}

abstract interface class PhilippineAddressLookup {
  Future<List<PsgcAddressOption>> provinces();
  Future<List<PsgcAddressOption>> citiesMunicipalities();
  Future<List<PsgcAddressOption>> barangays(String localityCode);
}

class PsgcAddressService implements PhilippineAddressLookup {
  PsgcAddressService({http.Client? client, this.baseUrl = _defaultBaseUrl})
    : _client = client ?? http.Client();

  static final PsgcAddressService instance = PsgcAddressService();
  static const _defaultBaseUrl = 'https://psgc.cloud/api/v2';

  final http.Client _client;
  final String baseUrl;
  Future<List<PsgcAddressOption>>? _provinces;
  Future<List<PsgcAddressOption>>? _localities;
  final Map<String, Future<List<PsgcAddressOption>>> _barangays = {};

  @override
  Future<List<PsgcAddressOption>> provinces() =>
      _provinces ??= _load('/provinces');

  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() =>
      _localities ??= _load('/cities-municipalities');

  @override
  Future<List<PsgcAddressOption>> barangays(String localityCode) =>
      _barangays.putIfAbsent(
        localityCode,
        () => _load('/cities-municipalities/$localityCode/barangays'),
      );

  Future<List<PsgcAddressOption>> _load(String path) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      final values = decoded is Map<String, Object?>
          ? decoded['data']
          : decoded;
      if (values is! List) return const [];
      return values
          .whereType<Map>()
          .map(
            (value) => PsgcAddressOption(
              code: _text(value['code']),
              name: _text(value['name']),
              province: _placeName(value['province'] ?? value['province_name']),
              provinceCode: _placeCode(
                value['province'] ?? value['province_code'],
              ),
              region: _placeName(value['region'] ?? value['region_name']),
            ),
          )
          .where((option) => option.code.isNotEmpty && option.name.isNotEmpty)
          .toList(growable: false);
    } on Exception {
      return const [];
    }
  }
}

String _text(Object? value) => value?.toString().trim() ?? '';

String _placeName(Object? value) => switch (value) {
  Map map => _text(map['name']),
  _ => _text(value),
};

String _placeCode(Object? value) => switch (value) {
  Map map => _text(map['code']),
  _ => _text(value),
};
