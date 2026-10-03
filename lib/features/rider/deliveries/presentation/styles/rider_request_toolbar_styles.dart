import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

abstract final class RiderRequestToolbarStyles {
  static InputDecoration inputDecoration(
    TextEditingController search,
    RiderDeliveryController controller,
    VoidCallback onSearchCleared,
  ) => InputDecoration(
    hintText: 'Search product, location, seller, or request number',
    prefixIcon: const Icon(Icons.search_rounded, size: 19),
    suffixIcon: search.text.isEmpty
        ? null
        : IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              search.clear();
              controller.setSearchText('');
              onSearchCleared();
            },
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
    filled: true,
    fillColor: AgrisellColors.surface,
    isDense: true,
  );

  static const inputDecoration2 = InputDecoration(
    labelText: 'Sort by',
    isDense: true,
  );

  static final dropdownButtonFormFieldStyle = AppDropdownStyle.textStyle
      .copyWith(fontSize: 12);
}
