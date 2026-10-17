import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/shared/location/presentation/styles/address_autocomplete_field_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'address_suggestion_entries.dart';

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
  final _menuController = MenuController();
  final _suggestionEntries = AddressSuggestionEntries();
  late String _text;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    widget.controller.addListener(_textChanged);
    _focusNode.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(covariant AddressAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.isEmpty &&
        widget.options.isNotEmpty &&
        _focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus && widget.options.isNotEmpty) {
          _menuController.open();
        }
      });
    }
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_textChanged);
    _text = widget.controller.text;
    _query = '';
    widget.controller.addListener(_textChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textChanged);
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _textChanged() {
    final text = widget.controller.text;
    // Cursor/composing changes are not address edits.
    if (text == _text) return;
    setState(() {
      _text = text;
      _query = _focusNode.hasFocus ? text.trim().toLowerCase() : '';
    });
    widget.onChanged(text);
  }

  void _focusChanged() {
    if (!_focusNode.hasFocus && _query.isNotEmpty) setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final entries = _suggestionEntries.resolve(widget.options, _query);
    if (entries.isEmpty && _menuController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _menuController.isOpen &&
            _suggestionEntries.resolve(widget.options, _query).isEmpty) {
          _menuController.close();
        }
      });
    }
    return Padding(
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
            menuController: _menuController,
            enabled: widget.enabled,
            focusNode: _focusNode,
            expandedInsets: EdgeInsets.zero,
            enableFilter: false,
            enableSearch: false,
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
            dropdownMenuEntries: entries,
            onSelected: (option) {
              if (option == null) return;
              widget.onSelected(option);
              setState(() => _query = '');
            },
          ),
        ],
      ),
    );
  }
}
