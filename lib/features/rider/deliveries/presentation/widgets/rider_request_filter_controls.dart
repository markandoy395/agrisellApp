import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_deliveries_design_styles.dart';

class RiderDistanceFilter extends StatelessWidget {
  const RiderDistanceFilter({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final maximum = value != null && value! > 50 ? value! : 50.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum pickup distance',
          style: RiderDeliveriesDesignStyles.label,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'Any distance'
                    : '${value!.toStringAsFixed(1)} km',
                style: RiderDeliveriesDesignStyles.caption,
              ),
            ),
            Switch(
              value: value != null,
              onChanged: (enabled) => onChanged(enabled ? 5 : null),
            ),
          ],
        ),
        Slider(
          value: (value ?? 5).clamp(0, maximum),
          max: maximum,
          activeColor: AgrisellColors.authGreen,
          label: value == null ? 'Any' : '${value!.round()} km',
          onChanged: value == null ? null : onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final km in [
              0,
              maximum / 4,
              maximum / 2,
              maximum * .75,
              maximum,
            ])
              Text(
                '${km.round()} km',
                style: RiderDeliveriesDesignStyles.caption,
              ),
          ],
        ),
      ],
    );
  }
}

class RiderDeadlineFilter extends StatelessWidget {
  const RiderDeadlineFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    super.key,
  });
  final String label;
  final int? value;
  final List<int> values;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: RiderDeliveriesDesignStyles.label),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        style: RiderDeliveriesDesignStyles.label,
        decoration: RiderDeliveriesDesignStyles.input(
          'Any time',
          prefix: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Any time')),
          for (final minutes in {...values, if (value != null) value!})
            DropdownMenuItem(
              value: minutes,
              child: Text('Within $minutes min'),
            ),
        ],
        onChanged: onChanged,
      ),
    ],
  );
}

class RiderEarningFilter extends StatelessWidget {
  const RiderEarningFilter({
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
    super.key,
  });
  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;
  final String? Function(double?)? validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: RiderDeliveriesDesignStyles.label),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: value?.toStringAsFixed(2),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: RiderDeliveriesDesignStyles.body,
        decoration: RiderDeliveriesDesignStyles.input(
          'Any amount',
          prefix: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('PHP'),
          ),
        ),
        onChanged: (text) => onChanged(double.tryParse(text)),
        validator: (text) {
          if (text == null || text.trim().isEmpty) return validator?.call(null);
          final amount = double.tryParse(text);
          if (amount == null || !amount.isFinite || amount < 0)
            return 'Enter a valid amount';
          return validator?.call(amount);
        },
      ),
    ],
  );
}
