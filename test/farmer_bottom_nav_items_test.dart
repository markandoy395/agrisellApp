import 'package:agresell_app/features/farmer/dashboard/data/farmer_bottom_nav_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product navigation uses full-size inventory icons', () {
    final products = farmerBottomNavItems.first;

    expect(products.label, 'Products');
    expect(products.iconData, Icons.inventory_2_outlined);
    expect(products.activeIconData, Icons.inventory_2_rounded);
    expect(products.icon, isNull);
    expect(products.activeIcon, isNull);
  });
}
