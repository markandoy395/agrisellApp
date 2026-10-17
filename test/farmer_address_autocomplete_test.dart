import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

void main() {
  test('PSGC service parses and caches address options', () async {
    var requests = 0;
    final service = PsgcAddressService(
      baseUrl: 'https://example.test/api/v2',
      client: MockClient((request) async {
        requests++;
        return http.Response(
          '{"data":[{"code":"1043000000","name":"Misamis Oriental",'
          '"region":"Region X (Northern Mindanao)"}]}',
          200,
        );
      }),
    );

    final first = await service.provinces();
    final second = await service.provinces();

    expect(first.single.name, 'Misamis Oriental');
    expect(first.single.region, 'Region X (Northern Mindanao)');
    expect(second.single.code, '1043000000');
    expect(requests, 1);
  });

  test('PSGC service reads a nested municipality province', () async {
    final service = PsgcAddressService(
      baseUrl: 'https://example.test/api/v2',
      client: MockClient(
        (_) async => http.Response(
          '{"data":[{"code":"1043050000","name":"Cagayan de Oro",'
          '"province":{"code":"1043000000","name":"Misamis Oriental"}}]}',
          200,
        ),
      ),
    );

    final locality = (await service.citiesMunicipalities()).single;

    expect(locality.province, 'Misamis Oriental');
    expect(locality.provinceCode, '1043000000');
  });

  testWidgets('farmer address supports suggestions and manual typing', (
    tester,
  ) async {
    final province = TextEditingController();
    final city = TextEditingController();
    final barangay = TextEditingController();
    addTearDown(() {
      province.dispose();
      city.dispose();
      barangay.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: PsgcAddressFields(
            provinceController: province,
            cityController: city,
            barangayController: barangay,
            lookup: const _AddressLookup(),
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextField, 'Province (select or type)'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Misamis Oriental'), findsOneWidget);
    await tester.tap(find.text('Misamis Oriental').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextField, 'City or municipality (select or type)'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cagayan de Oro — Misamis Oriental'), findsOneWidget);
    await tester.tap(find.text('Cagayan de Oro — Misamis Oriental'));
    await tester.pumpAndSettle();

    expect(province.text, 'Misamis Oriental');
    expect(city.text, 'Cagayan de Oro');
    expect(find.text('Region: Region X (Northern Mindanao)'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Barangay (select or type)'),
      'Custom Barangay',
    );
    expect(barangay.text, 'Custom Barangay');
  });

  testWidgets('duplicate municipality cannot replace selected province', (
    tester,
  ) async {
    final province = TextEditingController(text: 'Agusan del Sur');
    final city = TextEditingController();
    final barangay = TextEditingController();
    addTearDown(() {
      province.dispose();
      city.dispose();
      barangay.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsgcAddressFields(
            provinceController: province,
            cityController: city,
            barangayController: barangay,
            lookup: const _DuplicateLocalityLookup(),
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'City or municipality (select or type)'),
      'Esperanza',
    );
    await tester.pumpAndSettle();

    expect(province.text, 'Agusan del Sur');
    expect(city.text, 'Esperanza');
    expect(find.text('Region: Caraga'), findsOneWidget);
  });

  testWidgets('changing province rebuilds the municipality list', (
    tester,
  ) async {
    final province = TextEditingController(text: 'Masbate');
    final city = TextEditingController(text: 'Esperanza');
    final barangay = TextEditingController();
    addTearDown(() {
      province.dispose();
      city.dispose();
      barangay.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsgcAddressFields(
            provinceController: province,
            cityController: city,
            barangayController: barangay,
            lookup: const _DuplicateLocalityLookup(),
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextField, 'Province (select or type)'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agusan del Sur').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TextField, 'City or municipality (select or type)'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Esperanza \u2014 Agusan del Sur'), findsOneWidget);
    expect(find.text('Esperanza \u2014 Masbate'), findsNothing);
  });
  test(
    'PSGC service retries after a failed request instead of caching empty',
    () async {
      var attempts = 0;
      final service = PsgcAddressService(
        baseUrl: 'https://example.test/api/v2',
        client: MockClient((_) async {
          attempts++;
          if (attempts == 1) {
            return http.Response('gateway timeout', 504);
          }
          return http.Response(
            '{"data":[{"code":"1030500010","name":"Lapasan"}]}',
            200,
          );
        }),
      );

      final first = await service.barangays('1030500000');
      final second = await service.barangays('1030500000');

      expect(first, isEmpty);
      expect(second.single.name, 'Lapasan');
      expect(attempts, 2);
    },
  );
  test(
    'PSGC service retries after a failed request instead of caching empty',
    () async {
      var attempts = 0;
      final service = PsgcAddressService(
        baseUrl: 'https://example.test/api/v2',
        client: MockClient((_) async {
          attempts++;
          if (attempts == 1) {
            return http.Response('gateway timeout', 504);
          }
          return http.Response(
            '{"data":[{"code":"1030500010","name":"Lapasan"}]}',
            200,
          );
        }),
      );

      final first = await service.barangays('1030500000');
      final second = await service.barangays('1030500000');

      expect(first, isEmpty);
      expect(second.single.name, 'Lapasan');
      expect(attempts, 2);
    },
  );
}

class _AddressLookup implements PhilippineAddressLookup {
  const _AddressLookup();

  @override
  Future<List<PsgcAddressOption>> provinces() async => const [
    PsgcAddressOption(
      code: '1043000000',
      name: 'Misamis Oriental',
      region: 'Region X (Northern Mindanao)',
    ),
  ];

  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() async => const [
    PsgcAddressOption(
      code: '1043050000',
      name: 'Cagayan de Oro',
      province: 'Misamis Oriental',
      region: 'Region X (Northern Mindanao)',
    ),
  ];

  @override
  Future<List<PsgcAddressOption>> provinceCitiesMunicipalities(
    String provinceCode,
  ) async => const [];

  @override
  Future<List<PsgcAddressOption>> barangays(String localityCode) async =>
      const [PsgcAddressOption(code: '1043050010', name: 'Lapasan')];
}

class _DuplicateLocalityLookup implements PhilippineAddressLookup {
  const _DuplicateLocalityLookup();

  @override
  Future<List<PsgcAddressOption>> provinces() async => const [
    PsgcAddressOption(
      code: '1600300000',
      name: 'Agusan del Sur',
      region: 'Caraga',
    ),
    PsgcAddressOption(code: '0504100000', name: 'Masbate', region: 'Bicol'),
  ];

  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() async => const [
    PsgcAddressOption(
      code: '0504109000',
      name: 'Esperanza',
      province: 'Masbate',
      region: 'Bicol',
    ),
    PsgcAddressOption(
      code: '1600303000',
      name: 'Esperanza',
      province: 'Agusan del Sur',
      region: 'Caraga',
    ),
  ];

  @override
  Future<List<PsgcAddressOption>> provinceCitiesMunicipalities(
    String provinceCode,
  ) async => const [];

  @override
  Future<List<PsgcAddressOption>> barangays(String localityCode) async =>
      const [];
}
