import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/shared/location/presentation/styles/address_autocomplete_field_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    required this.onSelected,
    this.externalLabel,
    this.decorationTheme,
    this.leadingIcon,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final List<PsgcAddressOption> options;
  final ValueChanged<String> onChanged;
  final ValueChanged<PsgcAddressOption> onSelected;
  final Widget? externalLabel;
  final InputDecorationTheme? decorationTheme;
  final Widget? leadingIcon;
  final bool enabled;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textChanged);
  }

  @override
  void didUpdateWidget(covariant AddressAutocompleteField oldWidget) {
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.externalLabel != null) ...[
          widget.externalLabel!,
          const SizedBox(height: 8),
        ],
        DropdownMenu<PsgcAddressOption>(
          controller: widget.controller,
          enabled: widget.enabled,
          focusNode: _focusNode,
          expandedInsets: EdgeInsets.zero,
          enableFilter: true,
          enableSearch: true,
          requestFocusOnTap: true,
          menuHeight: 240,
          leadingIcon: widget.leadingIcon,
          label: widget.externalLabel != null
              ? null
              : Text(
                  '${widget.label} (select or type)',
                  style: SharedPresentationStyles.caption,
                ),
          textStyle: AddressAutocompleteFieldStyles.textStyle(
            widget.externalLabel,
          ),
          inputDecorationTheme:
              widget.decorationTheme ??
              AddressAutocompleteFieldStyles.inputTheme,
          menuStyle: SharedPresentationStyles.dropdownMenu,
          dropdownMenuEntries: widget.options
              .map(
                (option) => DropdownMenuEntry<PsgcAddressOption>(
                  value: option,
                  label: option.name,
                  labelWidget: Text(
                    option.province.isEmpty
                        ? option.name
                        : '${option.name} — ${option.province}',
                    style: SharedPresentationStyles.caption,
                  ),
                ),
              )
              .toList(growable: false),
          onSelected: (option) {
            if (option != null) widget.onSelected(option);
          },
        ),
      ],
    ),
  );
}
