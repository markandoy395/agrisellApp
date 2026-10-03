import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';

class RiderTemporaryDataNotice extends StatelessWidget {
  const RiderTemporaryDataNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: RiderAvailabilityCardStyles.alertDecoration,
      child: const Padding(
        padding: RiderAvailabilityCardStyles.noticePadding,
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AgrisellColors.statusOrangeText,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Availability is using local fallback data.',
                style: RiderAvailabilityCardStyles.noticeTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
