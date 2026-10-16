import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_messaging_design_styles.dart';

class RiderProtectedChatBanner extends StatelessWidget {
  const RiderProtectedChatBanner({
    this.deliveryId,
    this.compact = false,
    super.key,
  });
  final String? deliveryId;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 12 : 16),
    decoration: RiderMessagingDesignStyles.protected,
    child: Row(
      children: [
        Icon(
          compact ? Icons.lock_outline_rounded : Icons.verified_user_outlined,
          color: AgrisellColors.authGreen,
          size: compact ? 20 : 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                compact
                    ? 'Contact details remain private'
                    : deliveryId == null
                    ? 'Protected delivery chat'
                    : 'Protected conversation',
                style: RiderMessagingDesignStyles.title,
              ),
              if (!compact) ...[
                const SizedBox(height: 3),
                Text(
                  deliveryId == null
                      ? 'Contact details remain private in-app.'
                      : 'Delivery #$deliveryId',
                  style: RiderMessagingDesignStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
