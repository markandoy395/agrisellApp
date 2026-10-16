import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import '../../domain/rider_request_query.dart';
import '../controllers/rider_delivery_controller.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_request_filter_sheet.dart';

class RiderRequestToolbar extends StatefulWidget {
  const RiderRequestToolbar({required this.controller, super.key});
  final RiderDeliveryController controller;

  @override
  State<RiderRequestToolbar> createState() => _RiderRequestToolbarState();
}

class _RiderRequestToolbarState extends State<RiderRequestToolbar> {
  late final _search = TextEditingController(
    text: widget.controller.searchText,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _filters() async {
    final filters = await showRiderRequestFilterSheet(
      context,
      widget.controller.requestFilters,
      categories: widget.controller.requests
          .map((item) => item.productCategory)
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(),
    );
    if (!mounted || filters == null) return;
    widget.controller.applyRequestFilters(filters);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (value) {
                widget.controller.setSearchText(value);
                setState(() {});
              },
              textInputAction: TextInputAction.search,
              style: RiderDeliveriesDesignStyles.body,
              decoration: RiderDeliveriesDesignStyles.input(
                'Search delivery requests...',
                prefix: const Icon(Icons.search_rounded, size: 20),
                suffix: _search.text.isEmpty
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
              ),
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: widget.controller.requestFilters.activeCount > 0,
            label: Text('${widget.controller.requestFilters.activeCount}'),
            child: IconButton(
              tooltip: 'Filters',
              style: RiderDeliveriesDesignStyles.iconButton,
              onPressed: _filters,
              icon: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<RiderRequestSort>(
        dropdownColor: AppDropdownStyle.menuColor,
        borderRadius: AppDropdownStyle.menuBorderRadius,
        iconEnabledColor: AppDropdownStyle.iconColor,
        initialValue: widget.controller.requestSort,
        isExpanded: true,
        decoration: RiderDeliveriesDesignStyles.input('Sort by'),
        style: RiderDeliveriesDesignStyles.label,
        items: [
          for (final sort in RiderRequestSort.values)
            DropdownMenuItem(value: sort, child: Text(sort.label)),
        ],
        onChanged: (value) {
          if (value != null) widget.controller.setRequestSort(value);
        },
      ),
    ],
  );
}
