import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/registration/domain/philippine_crops.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_select_field.dart';

class FarmerSignupCropsField extends StatefulWidget {
  const FarmerSignupCropsField({
    required this.controller,
    required this.onChanged,
    this.error,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? error;

  @override
  State<FarmerSignupCropsField> createState() => _FarmerSignupCropsFieldState();
}

class _FarmerSignupCropsFieldState extends State<FarmerSignupCropsField> {
  @override
  Widget build(BuildContext context) {
    final selected = PhilippineCrops.parseSelection(widget.controller.text);
    final available =
        PhilippineCrops.names.where((crop) => !selected.contains(crop)).toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmerSignupDropdownStyle.field(
          context,
          label: 'Main crops',
          floating: selected.isNotEmpty,
          child: DropdownButtonFormField<String>(
            key: ValueKey('farmer-main-crops-${selected.join('|')}'),
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: FarmerSignupDropdownStyle.decoration(
              context,
              'Main crops',
              hint: selected.isEmpty ? 'Main crops' : 'Choose another crop',
            ),
            style: FarmerSignupDropdownStyle.valueStyle(context),
            items: available
                .map(
                  (crop) => DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(growable: false),
            onChanged: available.isEmpty ? null : _addCrop,
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final crop in selected)
                InputChip(
                  label: Text(crop, style: const TextStyle(fontSize: 11)),
                  onDeleted: () => _removeCrop(crop),
                  backgroundColor: AgrisellColors.forestSoft,
                  deleteIconColor: AgrisellColors.authGreen,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4),
            child: Text(
              widget.error!,
              style: const TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _addCrop(String? crop) {
    if (crop == null || !PhilippineCrops.names.contains(crop)) return;
    final selected = PhilippineCrops.parseSelection(widget.controller.text);
    if (selected.contains(crop)) return;
    setState(() => widget.controller.text = [...selected, crop].join(', '));
    widget.onChanged();
  }

  void _removeCrop(String crop) {
    final selected = PhilippineCrops.parseSelection(
      widget.controller.text,
    ).where((value) => value != crop).toList(growable: false);
    setState(() => widget.controller.text = selected.join(', '));
    widget.onChanged();
  }
}
