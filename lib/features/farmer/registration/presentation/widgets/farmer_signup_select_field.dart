import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AgrisellColors.brandBlack,
                      ),
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
            child: Text(
              error!,
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
}

abstract final class FarmerSignupDropdownStyle {
  static double height(BuildContext context) {
    final textSize = lerpDouble(
      12,
      14,
      authScale(MediaQuery.sizeOf(context).width),
    );
    final scaled = MediaQuery.textScalerOf(context).scale(textSize);
    return AuthInputStyle.height +
        (scaled - textSize).clamp(0.0, double.infinity) * 2;
  }

  static TextStyle valueStyle(BuildContext context) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, authScale(MediaQuery.sizeOf(context).width)),
    fontWeight: FontWeight.w400,
  );

  static Widget field(
    BuildContext context, {
    required String label,
    required bool floating,
    required Widget child,
  }) => SizedBox(
    height: height(context),
    child: Stack(
      children: [
        Positioned.fill(child: child),
        if (floating)
          Positioned(
            left: 10,
            right: 12,
            top: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: IgnorePointer(
                child: Container(
                  color: AuthInputStyle.fillColor,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AgrisellTheme.floatingInputLabelStyle,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  static InputDecoration decoration(
    BuildContext context,
    String label, {
    String? hint,
  }) => InputDecoration(
    hintText: hint ?? label,
    hintStyle: TextStyle(
      color: AgrisellColors.mutedText,
      fontSize: valueStyle(context).fontSize,
    ),
    isDense: true,
    filled: true,
    fillColor: AuthInputStyle.fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
    prefixIcon: AuthInputStyle.iconBadge(AuthInputStyle.iconFor(label)),
    prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 40),
    border: AuthInputStyle.border,
    enabledBorder: AuthInputStyle.border,
    focusedBorder: AuthInputStyle.focusedBorder,
  );
}
