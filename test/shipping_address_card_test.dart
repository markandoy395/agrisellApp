import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing shipping address can be set from the profile card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShippingAddressCard(
            address: '',
            onSave: (BuyerShippingAddress _) async {},
          ),
        ),
      ),
    );

    expect(find.text('No shipping address set'), findsOneWidget);
    await tester.tap(find.text('Set shipping address'));
    await tester.pump();

    expect(
      find.text('Choose your province, city, and barangay.'),
      findsOneWidget,
    );
    expect(find.text('Complete address'), findsOneWidget);
    expect(find.text('Tap to select the delivery pin'), findsOneWidget);
  });
}
