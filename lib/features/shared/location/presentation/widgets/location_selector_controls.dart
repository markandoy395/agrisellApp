import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class LocationSelectorHeader extends StatelessWidget {
  const LocationSelectorHeader({
    required this.centerPinMode,
    required this.onModeChanged,
    required this.onClose,
    required this.showModeSwitch,
    super.key,
  });

  final bool centerPinMode;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onClose;
  final bool showModeSwitch;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
    ),
    child: Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: AgrisellColors.deliveryGray,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose exact location',
                    style: TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Position the pin on the map to continue.',
                    style: TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close location selector',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        if (showModeSwitch) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.center_focus_strong_rounded, size: 16),
                  label: Text('Center pin'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.pan_tool_alt_outlined, size: 16),
                  label: Text('Drag pin'),
                ),
              ],
              selected: {centerPinMode},
              onSelectionChanged: (value) => onModeChanged(value.first),
              showSelectedIcon: false,
              style: const ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class LocationSelectorDetails extends StatelessWidget {
  const LocationSelectorDetails({
    required this.addressController,
    required this.notesController,
    required this.canConfirm,
    required this.saving,
    required this.onConfirm,
    required this.requiresWrittenAddress,
    required this.showFields,
    super.key,
  });

  final TextEditingController addressController;
  final TextEditingController notesController;
  final bool canConfirm;
  final bool saving;
  final VoidCallback onConfirm;
  final bool requiresWrittenAddress;
  final bool showFields;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        if (showFields)
          TextField(
            controller: addressController,
            style: const TextStyle(fontSize: 12),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: requiresWrittenAddress ? 'Written address' : 'Address',
              hintText: requiresWrittenAddress
                  ? 'Purok 5, Lianga, Surigao del Sur'
                  : null,
              helperText: requiresWrittenAddress
                  ? 'Required. Use a place name, not latitude and longitude.'
                  : 'Optional',
              filled: true,
              fillColor: AgrisellColors.searchBackground,
            ),
          ),
        if (showFields) const SizedBox(height: 6),
        if (showFields)
          TextField(
            controller: notesController,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              labelText: 'Landmark or notes',
              hintText: 'Farm entrance, gate, roadside',
              filled: true,
              fillColor: AgrisellColors.searchBackground,
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: FilledButton.icon(
            onPressed: canConfirm && !saving ? onConfirm : null,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: Text(saving ? 'Saving…' : 'Confirm Location'),
          ),
        ),
      ],
    ),
  );
}
