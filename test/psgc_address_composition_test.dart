import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_matching.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

void main() {
  for (final text in ['Sample City', 'sample city']) {
    test('automatic match preserves composition for $text', () {
      final province = TextEditingController();
      final city = TextEditingController.fromValue(
        TextEditingValue(
          text: text,
          selection: const TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 0, end: text.length),
        ),
      );
      final barangay = TextEditingController(text: 'Existing barangay');
      addTearDown(province.dispose);
      addTearDown(city.dispose);
      addTearDown(barangay.dispose);
      final before = city.value;
      const option = PsgcAddressOption(
        code: '1',
        name: 'Sample City',
        province: 'Sample Province',
      );
      expect(
        selectPsgcLocality(
          option: option,
          provinces: const [],
          provinceController: province,
          cityController: city,
          barangayController: barangay,
          clearBarangay: false,
        ),
        isTrue,
      );
      expect(city.value, before);
      expect(province.text, 'Sample Province');
      expect(barangay.text, 'Existing barangay');

      selectPsgcLocality(
        option: option,
        provinces: const [],
        provinceController: province,
        cityController: city,
        barangayController: barangay,
        clearBarangay: true,
      );
      expect(city.text, 'Sample City');
      expect(barangay.text, isEmpty);
    });
  }
}
