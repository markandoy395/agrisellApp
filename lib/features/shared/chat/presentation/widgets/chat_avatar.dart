export 'package:agresell_app/features/shared/chat/presentation/styles/chat_avatar_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_avatar_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({required this.participant, required this.style, super.key});

  final ChatParticipantData participant;
  final ChatAvatarStyle style;

  @override
  Widget build(BuildContext context) {
    final imageAsset = participant.imageAsset;
    if (imageAsset != null) {
      return CircleAvatar(
        radius: style.diameter / 2,
        backgroundColor: style.backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(style.diameter * .16),
          child: ResponsiveAssetImage(
            asset: imageAsset,
            width: style.diameter * .68,
            height: style.diameter * .68,
            fit: BoxFit.contain,
            semanticLabel: participant.imageSemanticLabel,
          ),
        ),
      );
    }
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
        style: ChatAvatarStyles.textStyle(style),
      ),
    );
  }
}
