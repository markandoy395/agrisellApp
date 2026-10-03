import 'package:agresell_app/features/shared/location/presentation/styles/location_selector_controls_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

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
    decoration: LocationSelectorControlsStyles.containerDecoration,
    child: Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: LocationSelectorControlsStyles.containerDecoration2,
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
                    style: SharedPresentationStyles.headingTitleExtraBold,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Position the pin on the map to continue.',
                    style: SharedPresentationStyles.mutedCaption,
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
              style: LocationSelectorControlsStyles.buttonStyle,
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
            style: SharedPresentationStyles.caption,
            textCapitalization: TextCapitalization.words,
            decoration: LocationSelectorControlsStyles.inputDecoration(
              requiresWrittenAddress,
            ),
          ),
        if (showFields) const SizedBox(height: 6),
        if (showFields)
          TextField(
            controller: notesController,
            style: SharedPresentationStyles.caption,
            decoration: LocationSelectorControlsStyles.inputDecoration2,
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
