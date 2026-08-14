import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';

class RiderQuickReplyRow extends StatelessWidget {
  const RiderQuickReplyRow({
    required this.replies,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final List<RiderQuickReply> replies;
  final bool enabled;
  final Future<bool> Function(String message) onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      scrollDirection: Axis.horizontal,
      itemCount: replies.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final reply = replies[index];
        return ActionChip(
          label: Text(reply.label),
          onPressed: enabled ? () => onSelected(reply.message) : null,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    ),
  );
}

class RiderConversationActionRow extends StatelessWidget {
  const RiderConversationActionRow({
    required this.enabled,
    required this.onAction,
    super.key,
  });

  final bool enabled;
  final ValueChanged<RiderCommunicationActionType> onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        _ActionButton(
          icon: Icons.share_location_outlined,
          label: 'Location',
          enabled: enabled,
          onTap: () => onAction(RiderCommunicationActionType.shareLocation),
        ),
        _ActionButton(
          icon: Icons.photo_camera_outlined,
          label: 'Photo',
          enabled: enabled,
          onTap: () => onAction(RiderCommunicationActionType.attachPhoto),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: TextButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AgrisellColors.authGreen,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class RiderMessageError extends StatelessWidget {
  const RiderMessageError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
    child: Text(
      message,
      style: const TextStyle(
        color: AgrisellColors.statusRedText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String riderActionLabel(RiderCommunicationActionType type) {
  return switch (type) {
    RiderCommunicationActionType.call => 'Protected call',
    RiderCommunicationActionType.shareLocation => 'Location sharing',
    RiderCommunicationActionType.attachPhoto => 'Photo sharing',
    RiderCommunicationActionType.contactSupport => 'Support',
  };
}
