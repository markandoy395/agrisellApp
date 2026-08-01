import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_action.dart';

Future<RiderSafetyActionType?> showRiderSafetySheet(BuildContext context) {
  return showModalBottomSheet<RiderSafetyActionType>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
        children: [
          const Text(
            'Safety & emergency',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final type in RiderSafetyActionType.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_icon(type), color: _color(type)),
              title: Text(
                type.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => Navigator.of(context).pop(type),
            ),
        ],
      ),
    ),
  );
}

Future<String?> showRiderSafetyReasonDialog(
  BuildContext context,
  RiderSafetyActionType type,
) async {
  if (!type.requiresReason) return null;
  final controller = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(type.label),
      content: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 4,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Describe the issue'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Submit report'),
        ),
      ],
    ),
  );
  controller.dispose();
  return reason == null || reason.isEmpty ? null : reason;
}

IconData _icon(RiderSafetyActionType type) => switch (type) {
  RiderSafetyActionType.emergencySos => Icons.sos_rounded,
  RiderSafetyActionType.reportProblem => Icons.flag_outlined,
  RiderSafetyActionType.unsafePickup ||
  RiderSafetyActionType.unsafeDelivery => Icons.warning_amber_rounded,
  RiderSafetyActionType.contactSupport => Icons.support_agent_rounded,
  RiderSafetyActionType.shareActiveLocation => Icons.share_location_outlined,
};

Color _color(RiderSafetyActionType type) =>
    type == RiderSafetyActionType.emergencySos
    ? AgrisellColors.statusRedText
    : AgrisellColors.authGreen;
