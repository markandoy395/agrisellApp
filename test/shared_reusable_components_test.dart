import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/payments/domain/farmer_gcash_details.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_date_of_birth_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_edit_action_button.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_edit_form_rows.dart';

void main() {
  test('shared peso formatter preserves whole and fractional amounts', () {
    expect(formatBasketPeso(125), '₱ 125');
    expect(formatBasketPeso(125.5), '₱ 125.50');
  });

  test('shared GCash details normalize backend values', () {
    final details = FarmerGcashDetails.fromJson({
      'farm_id': '42',
      'farmer_name': '  Ana  ',
      'account_name': ' Ana Dela Cruz ',
      'account_number': ' 09171234567 ',
    });

    expect(details.farmId, 42);
    expect(details.farmerName, 'Ana');
    expect(details.accountName, 'Ana Dela Cruz');
    expect(details.accountNumber, '09171234567');
    expect(details.isComplete, isTrue);
  });

  test('shared basket item preserves product pricing and selection', () {
    final item = BasketCartItem.fromProduct(_product, quantity: 2);

    expect(item.pricePerKg, 125.5);
    expect(item.selectedTotal, 251);
    expect(item.copyWith(isSelected: false).selectedTotal, 0);
  });

  testWidgets('shared profile controls preserve labels and callbacks', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Ana');
    addTearDown(controller.dispose);
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: Column(
              children: [
                ProfileEditFieldRow(label: 'Name', controller: controller),
                ProfileDateOfBirthRow(
                  value: const ProfileBirthDate(day: 15, month: 5, year: 1990),
                  onDayChanged: (_) {},
                  onMonthChanged: (_) {},
                  onYearChanged: (_) {},
                ),
                ProfileEditActionButton(
                  label: 'Save',
                  onPressed: () => saved = true,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('May'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(saved, isTrue);
    expect(tester.takeException(), isNull);
  });
}

const _product = HomeProduct(
  id: 'product-1',
  name: 'Tomato',
  price: '₱ 125.50',
  unit: 'kg',
  image: 'assets/images/vege.jpeg',
  harvestDate: 'Today',
  availableWeight: '12 kg',
  sellerName: 'Ana Farm',
  sellerLocation: 'Cagayan de Oro',
);
