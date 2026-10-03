import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_request_toolbar_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_filter_sheet.dart';

class RiderRequestToolbar extends StatefulWidget {
  const RiderRequestToolbar({required this.controller, super.key});
  final RiderDeliveryController controller;

  @override
  State<RiderRequestToolbar> createState() => _RiderRequestToolbarState();
}

class _RiderRequestToolbarState extends State<RiderRequestToolbar> {
  late final TextEditingController _search = TextEditingController(
    text: widget.controller.searchText,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: _search,
        onChanged: widget.controller.setSearchText,
        textInputAction: TextInputAction.search,
        style: SharedPresentationStyles.caption,
        decoration: RiderRequestToolbarStyles.inputDecoration(
          _search,
          widget.controller,
          () => setState(() {}),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<RiderRequestSort>(
              dropdownColor: AppDropdownStyle.menuColor,
              borderRadius: AppDropdownStyle.menuBorderRadius,
              iconEnabledColor: AppDropdownStyle.iconColor,
              initialValue: widget.controller.requestSort,
              isExpanded: true,
              decoration: RiderRequestToolbarStyles.inputDecoration2,
              style: RiderRequestToolbarStyles.dropdownButtonFormFieldStyle,
              items: [
                for (final sort in RiderRequestSort.values)
                  DropdownMenuItem(value: sort, child: Text(sort.label)),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.controller.setRequestSort(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: widget.controller.requestFilters.activeCount > 0,
            label: Text('${widget.controller.requestFilters.activeCount}'),
            child: OutlinedButton.icon(
              onPressed: () async {
                final filters = await showRiderRequestFilterSheet(
                  context,
                  widget.controller.requestFilters,
                  categories: widget.controller.requests
                      .map((item) => item.productCategory)
                      .where((item) => item.isNotEmpty)
                      .toSet()
                      .toList(),
                );
                if (filters != null) {
                  widget.controller.applyRequestFilters(filters);
                }
              },
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: const Text('Filters'),
            ),
          ),
        ],
      ),
    ],
  );
}
