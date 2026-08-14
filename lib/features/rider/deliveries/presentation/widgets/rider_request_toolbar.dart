import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Search product, location, seller, or request number',
          prefixIcon: const Icon(Icons.search_rounded, size: 19),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _search.clear();
                    widget.controller.setSearchText('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          filled: true,
          fillColor: AgrisellColors.surface,
          isDense: true,
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
              decoration: const InputDecoration(
                labelText: 'Sort by',
                isDense: true,
              ),
              style: AppDropdownStyle.textStyle.copyWith(fontSize: 12),
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
