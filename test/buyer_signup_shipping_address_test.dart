import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_shipping_address_fields.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

void main() {
  test(
    'signup requires street, province, city and barangay before assembling address',
    () {
      final form = SignUpFormControllers();
      addTearDown(form.dispose);
      form.shippingAddress.text = " 12 O'Neil %_* Street; -- ";
      expect(form.completeShippingAddress, isEmpty);
      form.shippingProvince.text = ' Misamis Oriental ';
      form.shippingCity.text = ' Cagayan de Oro ';
      expect(form.completeShippingAddress, isEmpty);
      form.shippingBarangay.text = ' Lapasan ';
      expect(
        form.toAccountData().shippingAddress,
        "12 O'Neil %_* Street; --, Barangay Lapasan, Cagayan de Oro, Misamis Oriental, Philippines",
      );
      form.shippingPostalCode.text = ' 9000 ';
      expect(
        form.toAccountData().shippingAddress,
        endsWith(', 9000, Philippines'),
      );
      form.shippingCity.clear();
      expect(form.completeShippingAddress, isEmpty);
    },
  );

  testWidgets(
    'buyer signup selects dependent address dropdowns and retains complete payload',
    (tester) async {
      final form = SignUpFormControllers();
      addTearDown(form.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SignUpShippingAddressFields(
                form: form,
                lookup: const _Lookup(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'House / street / purok'),
        'Purok 5',
      );
      for (final selection in {
        'Province (select or type)': 'Misamis Oriental',
        'City or municipality (select or type)':
            'Cagayan de Oro \u2014 Misamis Oriental',
        'Barangay (select or type)': 'Lapasan',
      }.entries) {
        final field = find.widgetWithText(TextField, selection.key);
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.tap(find.text(selection.value).last);
        await tester.pumpAndSettle();
      }
      expect(form.shippingProvince.text, 'Misamis Oriental');
      expect(form.shippingCity.text, 'Cagayan de Oro');
      expect(form.shippingBarangay.text, 'Lapasan');
      expect(
        form.toAccountData().shippingAddress,
        'Purok 5, Barangay Lapasan, Cagayan de Oro, Misamis Oriental, Philippines',
      );
    },
  );

  testWidgets(
    'buyer signup loads province municipalities when nationwide list is still empty and opens dropdown when async options arrive',
    (tester) async {
      final form = SignUpFormControllers();
      addTearDown(form.dispose);
      final lookup = _DelayedProvinceLookup();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SignUpShippingAddressFields(form: form, lookup: lookup),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final provinceField = find.widgetWithText(
        TextField,
        'Province (select or type)',
      );
      await tester.ensureVisible(provinceField);
      await tester.tap(provinceField);
      await tester.pumpAndSettle();
      expect(find.text('Zamboanga del Sur'), findsWidgets);
      await tester.tap(find.text('Misamis Oriental').last);
      await tester.pumpAndSettle();

      final cityField = find.widgetWithText(
        TextField,
        'City or municipality (select or type)',
      );
      await tester.ensureVisible(cityField);
      // Tap while province localities are still loading:
      await tester.tap(cityField);
      await tester.pumpAndSettle();
      lookup.completeProvinceCities();
      await tester.pumpAndSettle();

      expect(find.text('Cagayan de Oro \u2014 Misamis Oriental'), findsWidgets);
      await tester.tap(
        find.text('Cagayan de Oro \u2014 Misamis Oriental').last,
      );
      await tester.pumpAndSettle();

      final barangayField = find.widgetWithText(
        TextField,
        'Barangay (select or type)',
      );
      await tester.ensureVisible(barangayField);
      await tester.tap(barangayField);
      await tester.pumpAndSettle();
      expect(find.text('Lapasan'), findsWidgets);
    },
  );
}

class _Lookup implements PhilippineAddressLookup {
  const _Lookup();
  @override
  Future<List<PsgcAddressOption>> provinces() async => const [
    PsgcAddressOption(code: '1043000000', name: 'Misamis Oriental'),
  ];
  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() async => const [
    PsgcAddressOption(
      code: '1043050000',
      name: 'Cagayan de Oro',
      province: 'Misamis Oriental',
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

class _DelayedProvinceLookup implements PhilippineAddressLookup {
  final _completer = Completer<List<PsgcAddressOption>>();

  void completeProvinceCities() {
    if (_completer.isCompleted) return;
    _completer.complete(const [
      PsgcAddressOption(
        code: '1030500000',
        name: 'Cagayan de Oro',
        province: 'Misamis Oriental',
        provinceCode: '1004300000',
      ),
    ]);
  }

  @override
  Future<List<PsgcAddressOption>> provinces() async => const [
    PsgcAddressOption(code: '1004300000', name: 'Misamis Oriental'),
    PsgcAddressOption(code: '0907300000', name: 'Zamboanga del Sur'),
  ];

  @override
  Future<List<PsgcAddressOption>> citiesMunicipalities() async => const [];

  @override
  Future<List<PsgcAddressOption>> provinceCitiesMunicipalities(
    String provinceCode,
  ) => _completer.future;

  @override
  Future<List<PsgcAddressOption>> barangays(String localityCode) async =>
      const [PsgcAddressOption(code: '1030500010', name: 'Lapasan')];
}
