import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/data/device_phone_number_service.dart';

class PhoneNumberSyncControl extends StatefulWidget {
  const PhoneNumberSyncControl({
    required this.controller,
    this.onSynced,
    this.spacious = false,
    this.cardStyle = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSynced;
  final bool spacious;
  final bool cardStyle;

  @override
  State<PhoneNumberSyncControl> createState() => _PhoneNumberSyncControlState();
}

class _PhoneNumberSyncControlState extends State<PhoneNumberSyncControl> {
  bool _isSynced = false;
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.cardStyle) {
      return Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: PhoneNumberSyncControlStyles.containerDecoration,
        child: Row(
          children: [
            const Icon(Icons.sync_rounded, size: 26, color: Color(0xFF075239)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync contact to phone',
                    style: PhoneNumberSyncControlStyles.syncContactToPhoneText,
                  ),
                  Text(
                    'Easily find and connect with your contacts.',
                    style: PhoneNumberSyncControlStyles
                        .easilyFindAndConnectWithText,
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isSynced,
              onChanged: _isRequesting ? null : _onChanged,
            ),
          ],
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.spacious ? 56 : 42),
      child: Row(
        children: [
          Icon(Icons.sync_rounded, size: widget.spacious ? 24 : 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sync contact to phone',
              style: PhoneNumberSyncControlStyles.syncContactToPhoneText2(
                widget.spacious,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: _isSynced,
              onChanged: _isRequesting ? null : _onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onChanged(bool value) async {
    if (!value) {
      setState(() => _isSynced = false);
      return;
    }

    setState(() => _isRequesting = true);
    final selectedNumber = await DevicePhoneNumberService.requestNumber();
    if (!mounted) return;

    final normalized = selectedNumber == null
        ? null
        : PhilippinePhoneNumber.normalizeDeviceNumber(selectedNumber);
    if (normalized != null) {
      final displayNumber = PhilippinePhoneNumber.display(normalized);
      widget.controller.text = displayNumber;
      widget.onSynced?.call(displayNumber);
    }
    setState(() {
      _isRequesting = false;
      _isSynced = normalized != null;
    });

    final message = switch ((selectedNumber, normalized)) {
      (null, _) =>
        'No phone number was selected or found on this device. Enter it manually.',
      (_, null) => 'Select a valid Philippine mobile number.',
      _ => null,
    };
    if (message == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}
