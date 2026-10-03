import 'package:agresell_app/features/farmer/reservations/presentation/styles/buyer_message_sheet_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_reservation.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_chat_bubble.dart';

class BuyerMessageSheet extends StatelessWidget {
  const BuyerMessageSheet({required this.order, super.key});

  final FarmerReservation order;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BuyerMessageSheetStyles.containerDecoration,
              ),
            ),
            const SizedBox(height: 16),
            _BuyerMessageHeader(order: order),
            const SizedBox(height: 18),
            ReserveChatBubble(
              text: 'Hello, I reserved your available products.',
              isBuyer: true,
              name: order.buyerName,
            ),
            const SizedBox(height: 10),
            const ReserveChatBubble(
              text: 'Thanks. I will update you about the delivery schedule.',
              isBuyer: false,
              name: 'You',
            ),
            const SizedBox(height: 16),
            TextField(
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              decoration: BuyerMessageSheetStyles.inputDecoration(
                context,
                _messageBorder(AgrisellColors.borderLine),
                _messageBorder(AgrisellColors.authGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _messageBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class _BuyerMessageHeader extends StatelessWidget {
  const _BuyerMessageHeader({required this.order});

  final FarmerReservation order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AgrisellColors.statusGreenBackground,
          child: Text(
            order.buyerName.characters.first.toUpperCase(),
            style: SharedPresentationStyles.greenTitleExtraBold,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.buyerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BuyerMessageSheetStyles.textStyle,
              ),
              const SizedBox(height: 3),
              Text(
                order.contactNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BuyerMessageSheetStyles.textStyle2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
