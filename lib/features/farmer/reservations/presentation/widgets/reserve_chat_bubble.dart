import 'package:agresell_app/features/farmer/reservations/presentation/styles/reserve_chat_bubble_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ReserveChatBubble extends StatelessWidget {
  const ReserveChatBubble({
    required this.text,
    required this.isBuyer,
    required this.name,
    super.key,
  });

  final String text;
  final bool isBuyer;
  final String name;

  @override
  Widget build(BuildContext context) {
    final alignment = isBuyer ? Alignment.centerLeft : Alignment.centerRight;
    final background = isBuyer
        ? AgrisellColors.fieldFill
        : AgrisellColors.statusGreenBackground;
    final textColor = isBuyer
        ? AgrisellColors.brandBlack
        : AgrisellColors.authGreen;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: DecoratedBox(
          decoration: ReserveChatBubbleStyles.decoratedBoxDecoration(
            background,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReserveChatBubbleStyles.nameText(textColor),
                ),
                const SizedBox(height: 5),
                Text(text, style: ReserveChatBubbleStyles.textText(textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
