import 'package:flutter/material.dart';
import '../styles/rider_deliveries_design_styles.dart';

class RiderRequestCategoryFilter extends StatelessWidget {
  const RiderRequestCategoryFilter({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final List<String> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Category', style: RiderDeliveriesDesignStyles.label),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        style: RiderDeliveriesDesignStyles.label,
        decoration: RiderDeliveriesDesignStyles.input(
          'All categories',
          prefix: const Icon(Icons.category_outlined),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All categories')),
          for (final category in {...categories, if (value != null) value!})
            DropdownMenuItem(value: category, child: Text(category)),
        ],
        onChanged: onChanged,
      ),
    ],
  );
}

class RiderRequestFilterActions extends StatelessWidget {
  const RiderRequestFilterActions({
    required this.onReset,
    required this.onApply,
    super.key,
  });
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          style: RiderDeliveriesDesignStyles.secondary,
          onPressed: onReset,
          child: const Text('Reset filters'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: FilledButton(
          style: RiderDeliveriesDesignStyles.primary,
          onPressed: onApply,
          child: const Text('Apply filters'),
        ),
      ),
    ],
  );
}
