import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_gcash_settings_widgets_styles.dart';
import 'package:flutter/material.dart';

class FarmerGcashSettingsHeader extends StatelessWidget {
  const FarmerGcashSettingsHeader({required this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'GCash payment details',
          style: SharedPresentationStyles.headingTitleBlack,
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
    style: SharedPresentationStyles.body,
    onChanged: (_) => widget.onChanged(),
    decoration: FarmerGcashSettingsWidgetsStyles.inputDecoration(
      widget.label,
      widget.icon,
      widget.isPhone,
      _obscured,
      () => setState(() => _obscured = !_obscured),
    ),
  );
}
