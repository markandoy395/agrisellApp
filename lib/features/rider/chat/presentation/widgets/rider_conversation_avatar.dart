import 'package:flutter/material.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_communication_models.dart';
import '../styles/rider_messaging_design_styles.dart';

class RiderConversationAvatar extends StatelessWidget {
  const RiderConversationAvatar({
    required this.conversation,
    this.radius = 23,
    super.key,
  });
  final RiderConversation conversation;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = conversation.participantLabel
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: RiderMessagingDesignStyles.avatarColor(
        conversation.party,
      ),
      foregroundColor: AgrisellColors.authGreen,
      child: conversation.party == RiderConversationParty.support
          ? Padding(
              padding: EdgeInsets.all(radius * .32),
              child: ResponsiveAssetImage(
                asset: AgrisellAssets.logoOnly,
                width: radius * 1.36,
                height: radius * 1.36,
                fit: BoxFit.contain,
                semanticLabel: 'AgriSell support logo',
              ),
            )
          : Text(initials, style: RiderMessagingDesignStyles.title),
    );
  }
}
