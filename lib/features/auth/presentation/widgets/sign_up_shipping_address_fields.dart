import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/auth/presentation/styles/sign_up_screen_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';

class SignUpShippingAddressFields extends StatelessWidget {
  const SignUpShippingAddressFields({
    required this.form,
    this.enabled = true,
    this.lookup,
    super.key,
  });

  final SignUpFormControllers form;
  final bool enabled;
  final PhilippineAddressLookup? lookup;

  static void _noop() {}

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Shipping address', style: SignUpScreenStyles.sectionTitle),
      const SizedBox(height: SignUpScreenStyles.sectionHeaderGap),
      AuthTextField(
        controller: form.shippingAddress,
        hintText: 'House / street / purok',
        keyboardType: TextInputType.streetAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.streetAddressLine1],
        readOnly: !enabled,
      ),
      const SizedBox(height: 6),
      PsgcAddressFields(
        provinceController: form.shippingProvince,
        cityController: form.shippingCity,
        barangayController: form.shippingBarangay,
        lookup: lookup,
        enabled: enabled,
        onChanged: _noop,
        showSignupIcons: true,
        leadingIconBuilder: AuthInputStyle.iconBadge,
        decorationTheme: AuthInputStyle.dropdownTheme,
      ),
      AuthTextField(
        controller: form.shippingPostalCode,
        hintText: 'Postal code (optional)',
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.postalCode],
        readOnly: !enabled,
      ),
    ],
  );
}
