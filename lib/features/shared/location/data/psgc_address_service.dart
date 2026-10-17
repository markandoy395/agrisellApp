import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:agresell_app/features/shared/location/data/psgc_fallback_provinces.dart';

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
  Future<List<PsgcAddressOption>> provinceCitiesMunicipalities(
    String provinceCode,
  );
  Future<List<PsgcAddressOption>> barangays(String localityCode);
}

class PsgcAddressService implements PhilippineAddressLookup {
  PsgcAddressService({http.Client? client, this.baseUrl = _defaultBaseUrl})
    : _client = client ?? http.Client();

  static final PsgcAddressService instance = PsgcAddressService();
  static const _defaultBaseUrl = 'https://psgc.cloud/api/v2';
  static const _computeByteThreshold = 32768;

  final http.Client _client;
  final String baseUrl;
  Future<List<PsgcAddressOption>>? _provinces;
  Future<List<PsgcAddressOption>>? _localities;
  final Map<String, Future<List<PsgcAddressOption>>> _provinceLocalities = {};
  final Map<String, Future<List<PsgcAddressOption>>> _barangays = {};

  @override
  Future<List<PsgcAddressOption>> provinces() async {
    final future = _provinces ??= _load('/provinces');
    final values = await future;
    if (values.isNotEmpty) return values;
    if (identical(_provinces, future)) _provinces = null;
    return baseUrl == _defaultBaseUrl ? psgcFallbackProvinces : const [];
  }

  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() async {
    final future = _localities ??= _load('/cities-municipalities');
    final values = await future;
    if (values.isEmpty && identical(_localities, future)) _localities = null;
    return values;
  }

  @override
  Future<List<PsgcAddressOption>> provinceCitiesMunicipalities(
    String provinceCode,
  ) => _loadKeyed(
    _provinceLocalities,
    provinceCode,
    '/provinces/$provinceCode/cities-municipalities',
  );

  @override
  Future<List<PsgcAddressOption>> barangays(String localityCode) => _loadKeyed(
    _barangays,
    localityCode,
    '/cities-municipalities/$localityCode/barangays',
  );

  Future<List<PsgcAddressOption>> _loadKeyed(
    Map<String, Future<List<PsgcAddressOption>>> cache,
    String key,
    String path,
  ) async {
    final future = cache.putIfAbsent(key, () => _load(path));
    final values = await future;
    if (values.isEmpty && identical(cache[key], future)) cache.remove(key);
    return values;
  }

  Future<List<PsgcAddressOption>> _load(String path) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return const [];
      final bytes = response.bodyBytes;
      if (bytes.length <= _computeByteThreshold) {
        return _parseAddressOptions(bytes);
      }
      return await compute(_parseAddressOptions, bytes);
    } catch (_) {
      return const [];
    }
  }
}

// Decode and construct the complete result off the UI isolate on native targets.
List<PsgcAddressOption> _parseAddressOptions(Uint8List bytes) {
  final decoded = jsonDecode(utf8.decode(bytes));
  final values = decoded is Map<String, Object?> ? decoded['data'] : decoded;
  if (values is! List) return const [];
  return values
      .whereType<Map>()
      .map(
        (value) => PsgcAddressOption(
          code: _text(value['code']),
          name: _text(value['name']),
          province: _placeName(value['province'] ?? value['province_name']),
          provinceCode: _placeCode(value['province'] ?? value['province_code']),
          region: _placeName(value['region'] ?? value['region_name']),
        ),
      )
      .where((option) => option.code.isNotEmpty && option.name.isNotEmpty)
      .toList(growable: false);
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
