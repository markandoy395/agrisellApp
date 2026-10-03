import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_request_filter_sheet_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_filter_choices.dart';

Future<RiderRequestFilters?> showRiderRequestFilterSheet(
  BuildContext context,
  RiderRequestFilters initial, {
  List<String> categories = const [],
}) => showModalBottomSheet<RiderRequestFilters>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) =>
      _RiderRequestFilterSheet(initial: initial, categories: categories),
);

class _RiderRequestFilterSheet extends StatefulWidget {
  const _RiderRequestFilterSheet({
    required this.initial,
    required this.categories,
  });
  final RiderRequestFilters initial;
  final List<String> categories;

  @override
  State<_RiderRequestFilterSheet> createState() =>
      _RiderRequestFilterSheetState();
}

class _RiderRequestFilterSheetState extends State<_RiderRequestFilterSheet> {
  late bool _urgent = widget.initial.urgentOnly;
  late bool _scheduled = widget.initial.scheduledOnly;
  late bool _perishable = widget.initial.perishableOnly;
  late double? _distance = widget.initial.maximumPickupDistanceKm;
  late double? _minimumFee = widget.initial.minimumFee;
  late double? _maximumFee = widget.initial.maximumFee;
  late String? _category = widget.initial.category;
  late int? _pickupMinutes = widget.initial.pickupWithinMinutes;
  late int? _deliveryMinutes = widget.initial.deliveryWithinMinutes;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: RiderRequestFilterSheetStyles.sheetPadding(
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter nearby requests',
              style: RiderRequestFilterSheetStyles.headerTitleStyle,
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Urgent only'),
              value: _urgent,
              onChanged: (value) => setState(() => _urgent = value ?? false),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Scheduled only'),
              value: _scheduled,
              onChanged: (value) => setState(() => _scheduled = value ?? false),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Perishable only'),
              value: _perishable,
              onChanged: (value) =>
                  setState(() => _perishable = value ?? false),
            ),
            RiderRequestFilterSheetStyles.sectionSpacing,
            RiderDoubleFilterChoices(
              label: 'Maximum pickup distance',
              value: _distance,
              values: const [5, 10, 15],
              formatLabel: (val) => '${val.round()} km',
              onChanged: (val) => setState(() => _distance = val),
            ),
            if (widget.categories.isNotEmpty) ...[
              RiderRequestFilterSheetStyles.sectionSpacing,
              DropdownButtonFormField<String?>(
                dropdownColor: AppDropdownStyle.menuColor,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                style: AppDropdownStyle.textStyle,
                iconEnabledColor: AppDropdownStyle.iconColor,
                initialValue: _category,
                decoration:
                    RiderRequestFilterSheetStyles.categoryInputDecoration,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (final category in widget.categories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
            ],
            RiderRequestFilterSheetStyles.sectionSpacing,
            RiderMinuteFilterChoices(
              label: 'Pickup deadline within',
              value: _pickupMinutes,
              values: const [30, 60, 120],
              onChanged: (value) => setState(() => _pickupMinutes = value),
            ),
            RiderMinuteFilterChoices(
              label: 'Delivery deadline within',
              value: _deliveryMinutes,
              values: const [60, 120, 240],
              onChanged: (value) => setState(() => _deliveryMinutes = value),
            ),
            RiderRequestFilterSheetStyles.sectionSpacing,
            RiderDoubleFilterChoices(
              label: 'Minimum estimated earning',
              value: _minimumFee,
              values: const [100, 150, 200],
              formatLabel: (val) => 'PHP ${val.round()}',
              onChanged: (val) => setState(() => _minimumFee = val),
            ),
            RiderRequestFilterSheetStyles.sectionSpacing,
            RiderDoubleFilterChoices(
              label: 'Maximum estimated earning',
              value: _maximumFee,
              values: const [150, 200, 250],
              formatLabel: (val) => 'PHP ${val.round()}',
              onChanged: (val) => setState(() => _maximumFee = val),
            ),
            RiderRequestFilterSheetStyles.actionSpacing,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const RiderRequestFilters()),
                    child: const Text('Reset filters'),
                  ),
                ),
                RiderRequestFilterSheetStyles.buttonSpacing,
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      RiderRequestFilters(
                        urgentOnly: _urgent,
                        scheduledOnly: _scheduled,
                        perishableOnly: _perishable,
                        maximumPickupDistanceKm: _distance,
                        minimumFee: _minimumFee,
                        maximumFee: _maximumFee,
                        category: _category,
                        pickupWithinMinutes: _pickupMinutes,
                        deliveryWithinMinutes: _deliveryMinutes,
                      ),
                    ),
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
