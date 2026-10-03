export 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_select_field_styles.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_select_field_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

class FarmerSignupSelectField extends StatelessWidget {
  const FarmerSignupSelectField({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.error,
    this.optionLabels = const {},
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;
  final Map<String, String> optionLabels;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final selected = options.contains(controller.text) ? controller.text : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmerSignupDropdownStyle.field(
          context,
          label: label,
          floating: selected != null,
          child: DropdownButtonFormField<String>(
            key: ValueKey('farmer-$label-options'),
            initialValue: selected,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: FarmerSignupDropdownStyle.decoration(context, label),
            style: FarmerSignupDropdownStyle.valueStyle(context),
            selectedItemBuilder: (context) => options
                .map(
                  (value) => Tooltip(
                    message: optionLabels[value] ?? value,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        optionLabels[value] ?? value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
            items: options
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      optionLabels[value] ?? value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FarmerSignupSelectFieldStyles.textStyle,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              controller.text = value;
              onChanged(value);
            },
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4),
            child: Text(error!, style: SharedPresentationStyles.errorCaption),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
