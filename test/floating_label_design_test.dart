import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_options_field.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/address_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app input theme uses the shared floating-label design', () {
    expect(
      AgrisellTheme.light.inputDecorationTheme.floatingLabelStyle,
      AgrisellTheme.floatingInputLabelStyle,
    );
  });

  testWidgets('custom auth field uses the shared floating-label design', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'buyer@example.com');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: AuthTextField(
            hintText: 'Email or phone number',
            controller: controller,
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('auth-floating-label')),
        matching: find.byType(Text),
      ),
    );
    expect(label.style, AgrisellTheme.floatingInputLabelStyle);
  });

  testWidgets('dropdown fields keep the shared floating-label design', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerSignupOptionsField(
            label: 'Province',
            controller: controller,
            options: const ['Batangas'],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final dropdown = tester.widget<DropdownMenu<String>>(
      find.byType(DropdownMenu<String>),
    );
    expect(
      dropdown.inputDecorationTheme?.floatingLabelStyle,
      AgrisellTheme.floatingInputLabelStyle,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: AddressAutocompleteField(
            label: 'City or municipality',
            controller: controller,
            options: const [
              PsgcAddressOption(code: '0410', name: 'Batangas City'),
            ],
            onChanged: (_) {},
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final addressDropdown = tester.widget<DropdownMenu<PsgcAddressOption>>(
      find.byType(DropdownMenu<PsgcAddressOption>),
    );
    expect(
      addressDropdown.inputDecorationTheme?.floatingLabelStyle,
      AgrisellTheme.floatingInputLabelStyle,
    );
  });
}
