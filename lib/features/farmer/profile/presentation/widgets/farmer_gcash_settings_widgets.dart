import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerGcashSettingsHeader extends StatelessWidget {
  const FarmerGcashSettingsHeader({required this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'GCash payment details',
          style: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      IconButton(
        tooltip: 'Close GCash settings',
        onPressed: onClose,
        icon: const Icon(Icons.close_rounded, size: 20),
      ),
    ],
  );
}

class FarmerGcashSettingsField extends StatefulWidget {
  const FarmerGcashSettingsField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onChanged,
    this.isPhone = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onChanged;
  final bool isPhone;

  @override
  State<FarmerGcashSettingsField> createState() =>
      _FarmerGcashSettingsFieldState();
}

class _FarmerGcashSettingsFieldState extends State<FarmerGcashSettingsField> {
  late var _obscured = widget.isPhone;

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    keyboardType: widget.isPhone ? TextInputType.phone : TextInputType.name,
    enabled: widget.enabled,
    obscureText: widget.isPhone && _obscured,
    maxLength: widget.isPhone ? 20 : 80,
    style: const TextStyle(fontSize: 13),
    onChanged: (_) => widget.onChanged(),
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: Icon(widget.icon, size: 19),
      suffixIcon: widget.isPhone
          ? IconButton(
              tooltip: _obscured ? 'Show GCash number' : 'Hide GCash number',
              onPressed: () => setState(() => _obscured = !_obscured),
              icon: Icon(
                _obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
              ),
            )
          : null,
      filled: true,
      fillColor: AgrisellColors.searchBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
