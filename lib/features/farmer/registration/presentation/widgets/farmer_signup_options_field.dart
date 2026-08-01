import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class FarmerSignupOptionsField extends StatefulWidget {
  const FarmerSignupOptionsField({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.error,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  State<FarmerSignupOptionsField> createState() =>
      _FarmerSignupOptionsFieldState();
}

class _FarmerSignupOptionsFieldState extends State<FarmerSignupOptionsField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textChanged);
  }

  @override
  void didUpdateWidget(covariant FarmerSignupOptionsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_textChanged);
    widget.controller.addListener(_textChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textChanged);
    super.dispose();
  }

  void _textChanged() => widget.onChanged(widget.controller.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          key: ValueKey('farmer-${widget.label}-options'),
          controller: widget.controller,
          expandedInsets: EdgeInsets.zero,
          enableFilter: true,
          enableSearch: true,
          requestFocusOnTap: true,
          menuHeight: 240,
          label: Text(
            '${widget.label} (select or type)',
            style: const TextStyle(fontSize: 12),
          ),
          textStyle: const TextStyle(fontSize: 12),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            filled: true,
            fillColor: AgrisellColors.fieldFill,
            constraints: const BoxConstraints.tightFor(height: 56),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          menuStyle: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(AgrisellColors.surface),
          ),
          dropdownMenuEntries: widget.options
              .map(
                (option) => DropdownMenuEntry<String>(
                  value: option,
                  label: option,
                  labelWidget: Text(
                    option,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
            child: Text(
              widget.error!,
              style: const TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
              ),
            ),
          ),
      ],
    ),
  );
}
