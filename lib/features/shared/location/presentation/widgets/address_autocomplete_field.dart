import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'address_suggestion_entries.dart';
import 'address_suggestion_menu.dart';

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
  bool _selecting = false;

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
    if (_selecting || text == _text) return;
    setState(() {
      _text = text;
      _query = _focusNode.hasFocus ? text.trim().toLowerCase() : '';
    });
    widget.onChanged(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.enabled &&
          _focusNode.hasFocus &&
          _suggestionEntries.resolve(widget.options, _query).isNotEmpty) {
        _menuController.open();
      }
    });
  }

  void _focusChanged() {
    if (!_focusNode.hasFocus && _query.isNotEmpty) setState(() => _query = '');
  }

  void _select(PsgcAddressOption option) {
    _selecting = true;
    try {
      widget.controller.value = TextEditingValue(
        text: option.name,
        selection: TextSelection.collapsed(offset: option.name.length),
      );
      widget.onSelected(option);
    } finally {
      _selecting = false;
    }
    _menuController.close();
    setState(() {
      _text = widget.controller.text;
      _query = '';
    });
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
          AddressSuggestionMenu(
            controller: widget.controller,
            menuController: _menuController,
            enabled: widget.enabled,
            focusNode: _focusNode,
            leadingIcon: widget.leadingIcon,
            label: widget.label,
            externalLabel: widget.externalLabel,
            decorationTheme: widget.decorationTheme,
            entries: entries,
            onSelected: _select,
          ),
        ],
      ),
    );
  }
}
