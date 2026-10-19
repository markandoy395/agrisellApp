import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/presentation/styles/address_autocomplete_field_styles.dart';

/// A bounded menu avoids intrinsic measurement of every suggestion on each edit.
class AddressSuggestionMenu extends StatelessWidget {
  const AddressSuggestionMenu({
    required this.controller,
    required this.focusNode,
    required this.menuController,
    required this.entries,
    required this.onSelected,
    required this.label,
    required this.enabled,
    this.externalLabel,
    this.leadingIcon,
    this.decorationTheme,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final MenuController menuController;
  final List<DropdownMenuEntry<PsgcAddressOption>> entries;
  final ValueChanged<PsgcAddressOption> onSelected;
  final String label;
  final bool enabled;
  final Widget? externalLabel;
  final Widget? leadingIcon;
  final InputDecorationTheme? decorationTheme;

  void _open() {
    if (enabled && entries.isNotEmpty) menuController.open();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => MenuAnchor(
      controller: menuController,
      childFocusNode: focusNode,
      crossAxisUnconstrained: false,
      style: SharedPresentationStyles.dropdownMenu,
      menuChildren: [
        SizedBox(
          width: constraints.maxWidth,
          height: math.min(entries.length * 48.0, 240),
          child: ListView.builder(
            primary: false,
            padding: EdgeInsets.zero,
            itemExtent: 48,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return MenuItemButton(
                onPressed: () => onSelected(entry.value),
                child: entry.labelWidget ?? Text(entry.label),
              );
            },
          ),
        ),
      ],
      builder: (context, menu, child) => TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        style: AddressAutocompleteFieldStyles.textStyle(externalLabel),
        decoration: AddressAutocompleteFieldStyles.decoration(
          label: label,
          externalLabel: externalLabel,
          leadingIcon: leadingIcon,
          theme: decorationTheme,
          onToggle: enabled
              ? () {
                  if (menu.isOpen) {
                    menu.close();
                  } else {
                    focusNode.requestFocus();
                    _open();
                  }
                }
              : null,
        ),
        onTap: _open,
        onChanged: (_) => _open(),
        onSubmitted: (_) {
          if (entries.length == 1) onSelected(entries.single.value);
        },
      ),
    ),
  );
}
