import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_security_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'login and signup input surfaces share height and text alignment',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.binding.setSurfaceSize(null);
      });
      for (final width in [320.0, 430.0]) {
        await tester.binding.setSurfaceSize(Size(width, 932));
        await tester.pumpWidget(_fieldSamples());
        await tester.pump();

        for (final field in find.byType(AuthTextField).evaluate()) {
          final finder = find.byWidget(field.widget);
          _expectSurfaceAndTextCentered(tester, finder);
          _expectReferenceStyle(tester, finder);
        }
        for (final field in find.byType(RiderSignUpTextField).evaluate()) {
          final finder = find.byWidget(field.widget);
          _expectSurfaceAndTextCentered(tester, finder);
          _expectReferenceStyle(tester, finder);
        }
        _expectSurfaceAndTextCentered(
          tester,
          find.byType(RiderSignUpPasswordField),
        );
        _expectReferenceStyle(tester, find.byType(RiderSignUpPasswordField));

        for (final label in ['Gender', 'Rider date', 'Rider vehicle']) {
          final decorator = find.byWidgetPredicate(
            (widget) =>
                widget is InputDecorator &&
                widget.decoration.labelText == label,
          );
          expect(
            tester.getSize(decorator).height,
            56,
            reason: '$label at $width px',
          );
          _expectReferenceStyle(tester, decorator);
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}

Widget _fieldSamples() => MaterialApp(
  theme: AgrisellTheme.light,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const AuthTextField(
            hintText: 'Login email',
            leadingIcon: Icons.person_outline,
          ),
          const AuthTextField(
            hintText: 'Login password',
            leadingIcon: Icons.lock_outline,
            showPasswordToggle: true,
          ),
          const AuthTextField(hintText: 'Buyer email'),
          const AuthTextField(
            hintText: 'Farmer email',
            leadingIcon: Icons.mail_outline,
            leadingIconBadge: true,
          ),
          const AuthTextField(
            hintText: 'Farmer address',
            leadingIcon: Icons.location_on_outlined,
            trailingIcon: Icons.chevron_right,
          ),
          DropdownButtonFormField<String>(
            decoration: AuthInputStyle.decoration(
              label: 'Gender',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 16,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (_) {},
          ),
          RiderSignUpTextField(
            label: 'Rider email',
            value: '',
            onChanged: (_) {},
          ),
          RiderSignUpPasswordField(
            label: 'Rider password',
            value: '',
            onChanged: (_) {},
          ),
          InputDecorator(
            decoration: AuthInputStyle.decoration(
              label: 'Rider date',
              contentPadding: riderSignUpSelectionContentPadding,
            ),
            child: const Row(
              children: [
                Expanded(child: Text('Select date')),
                Icon(Icons.calendar_month_outlined),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            decoration: AuthInputStyle.decoration(
              label: 'Rider vehicle',
              contentPadding: riderSignUpSelectionContentPadding,
            ),
            items: const [DropdownMenuItem(value: 'Bike', child: Text('Bike'))],
            onChanged: (_) {},
          ),
        ],
      ),
    ),
  ),
);

void _expectSurfaceAndTextCentered(WidgetTester tester, Finder field) {
  final surface = find.descendant(
    of: field,
    matching: find.byType(InputDecorator),
  );
  final editable = find.descendant(
    of: field,
    matching: find.byType(EditableText),
  );
  final surfaceRect = tester.getRect(surface);
  final textRect = tester.getRect(editable);
  expect(surfaceRect.height, 56);
  expect(textRect.center.dy, closeTo(surfaceRect.center.dy, 1));
}

void _expectReferenceStyle(WidgetTester tester, Finder field) {
  final decorator = field.evaluate().single.widget is InputDecorator
      ? field
      : find.descendant(of: field, matching: find.byType(InputDecorator));
  final decoration = tester.widget<InputDecorator>(decorator).decoration;
  expect(decoration.filled, isTrue);
  expect(decoration.fillColor, AuthInputStyle.fillColor);
  expect(decoration.prefixIcon, isNotNull);
  expect(decoration.border, AuthInputStyle.border);
}
