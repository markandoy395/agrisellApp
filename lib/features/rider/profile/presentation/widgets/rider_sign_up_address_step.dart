import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';

class RiderSignUpAddressStep extends StatefulWidget {
  const RiderSignUpAddressStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  State<RiderSignUpAddressStep> createState() => _RiderSignUpAddressStepState();
}

class _RiderSignUpAddressStepState extends State<RiderSignUpAddressStep> {
  late final _street = _controller(RiderSignUpFields.addressLine);
  late final _province = _controller(RiderSignUpFields.province);
  late final _city = _controller(RiderSignUpFields.cityMunicipality);
  late final _barangay = _controller(RiderSignUpFields.barangay);
  late final _postal = _controller(RiderSignUpFields.postalCode);

  RiderSignUpController get controller => widget.controller;
  TextEditingController _controller(String key) =>
      TextEditingController(text: controller.draft.value(key));

  @override
  void dispose() {
    for (final item in [_street, _province, _city, _barangay, _postal]) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your official address by province, city or municipality, and barangay. We will capture your exact GPS location when you continue.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
        const SizedBox(height: 12),
        _field(
          'House, building, street, or sitio',
          _street,
          RiderSignUpFields.addressLine,
          TextInputType.streetAddress,
        ),
        PsgcAddressFields(
          provinceController: _province,
          cityController: _city,
          barangayController: _barangay,
          onChanged: _saveAddress,
          showSignupIcons: true,
          leadingIconBuilder: AuthInputStyle.iconBadge,
          decorationTheme: AuthInputStyle.dropdownTheme,
        ),
        _field(
          'Postal code (optional)',
          _postal,
          RiderSignUpFields.postalCode,
          TextInputType.number,
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController field,
    String key,
    TextInputType type,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: field,
      keyboardType: type,
      onChanged: (_) => _saveAddress(),
      decoration: AuthInputStyle.decoration(
        label: label,
        errorText: controller.errorFor(key),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 19),
      ),
    ),
  );

  void _saveAddress() {
    controller.updateAddress(
      addressLine: _street.text,
      province: _province.text,
      cityMunicipality: _city.text,
      barangay: _barangay.text,
      postalCode: _postal.text,
      location: RiderAddress.format(
        addressLine: _street.text,
        barangay: _barangay.text,
        cityMunicipality: _city.text,
        province: _province.text,
        postalCode: _postal.text,
      ),
    );
  }
}
