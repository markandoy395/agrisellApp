import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';

class ChatAvatarStyle {
  const ChatAvatarStyle({
    required this.diameter,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textStyle,
  });

  final double diameter;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle textStyle;
}

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({required this.participant, required this.style, super.key});

  final ChatParticipantData participant;
  final ChatAvatarStyle style;

  @override
  Widget build(BuildContext context) {
    final imageUrl = participant.imageUrl;
    if (imageUrl != null) {
      return ClipOval(
        child: ResponsiveAssetImage(
          imageUrl: imageUrl,
          width: style.diameter,
          height: style.diameter,
          fit: BoxFit.cover,
          semanticLabel: participant.imageSemanticLabel,
        ),
      );
    }

    return CircleAvatar(
      radius: style.diameter / 2,
      backgroundColor: style.backgroundColor,
      child: Text(
        participant.initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: style.textStyle.copyWith(color: style.foregroundColor),
      ),
    );
  }
}
