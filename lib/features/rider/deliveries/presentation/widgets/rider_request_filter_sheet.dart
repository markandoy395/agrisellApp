import 'package:flutter/material.dart';
import '../../domain/rider_request_query.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_request_filter_controls.dart';
import 'rider_request_category_filter.dart';

Future<RiderRequestFilters?> showRiderRequestFilterSheet(
  BuildContext context,
  RiderRequestFilters initial, {
  List<String> categories = const [],
}) => showModalBottomSheet<RiderRequestFilters>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
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
  final _form = GlobalKey<FormState>();
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
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filter nearby requests',
                            style: RiderDeliveriesDesignStyles.title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close filters',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    _toggle(
                      'Urgent only',
                      Icons.error_outline,
                      _urgent,
                      (value) => setState(() => _urgent = value),
                    ),
                    _toggle(
                      'Scheduled only',
                      Icons.calendar_today_outlined,
                      _scheduled,
                      (value) => setState(() => _scheduled = value),
                    ),
                    _toggle(
                      'Perishable only',
                      Icons.eco_outlined,
                      _perishable,
                      (value) => setState(() => _perishable = value),
                    ),
                    const Divider(height: 24),
                    RiderDistanceFilter(
                      value: _distance,
                      onChanged: (value) => setState(() => _distance = value),
                    ),
                    const SizedBox(height: 18),
                    RiderRequestCategoryFilter(
                      categories: widget.categories,
                      value: _category,
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: 18),
                    RiderDeadlineFilter(
                      label: 'Pickup deadline',
                      value: _pickupMinutes,
                      values: const [30, 60, 120],
                      onChanged: (value) =>
                          setState(() => _pickupMinutes = value),
                    ),
                    const SizedBox(height: 18),
                    RiderDeadlineFilter(
                      label: 'Delivery deadline',
                      value: _deliveryMinutes,
                      values: const [60, 120, 240],
                      onChanged: (value) =>
                          setState(() => _deliveryMinutes = value),
                    ),
                    const SizedBox(height: 18),
                    RiderEarningFilter(
                      label: 'Minimum estimated earning',
                      value: _minimumFee,
                      onChanged: (value) => _minimumFee = value,
                    ),
                    const SizedBox(height: 18),
                    RiderEarningFilter(
                      label: 'Maximum estimated earning',
                      value: _maximumFee,
                      onChanged: (value) => _maximumFee = value,
                      validator: (value) =>
                          value != null &&
                              _minimumFee != null &&
                              value < _minimumFee!
                          ? 'Must be at least the minimum earning'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          RiderRequestFilterActions(
            onReset: () => Navigator.pop(context, const RiderRequestFilters()),
            onApply: _apply,
          ),
        ],
      ),
    ),
  );

  Widget _toggle(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    secondary: Icon(icon),
    title: Text(label, style: RiderDeliveriesDesignStyles.body),
    value: value,
    onChanged: onChanged,
  );

  void _apply() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
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
    );
  }
}
