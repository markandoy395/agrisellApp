import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

class FarmerAddressAutocompleteField extends StatefulWidget {
  const FarmerAddressAutocompleteField({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    required this.onSelected,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final List<PsgcAddressOption> options;
  final ValueChanged<String> onChanged;
  final ValueChanged<PsgcAddressOption> onSelected;

  @override
  State<FarmerAddressAutocompleteField> createState() =>
      _FarmerAddressAutocompleteFieldState();
}

class _FarmerAddressAutocompleteFieldState
    extends State<FarmerAddressAutocompleteField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textChanged);
  }

  @override
  void didUpdateWidget(covariant FarmerAddressAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_textChanged);
    widget.controller.addListener(_textChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _textChanged() => widget.onChanged(widget.controller.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: DropdownMenu<PsgcAddressOption>(
      controller: widget.controller,
      focusNode: _focusNode,
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
            (option) => DropdownMenuEntry<PsgcAddressOption>(
              value: option,
              label: option.name,
              labelWidget: Text(
                option.province.isEmpty
                    ? option.name
                    : '${option.name} — ${option.province}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
          .toList(growable: false),
      onSelected: (option) {
        if (option != null) widget.onSelected(option);
      },
    ),
  );
}
