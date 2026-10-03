part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState({required this.filter});

  final OrderTrackingFilter filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: EmptyOrderStateStyles.containerDecoration,
              child: Icon(
                filter.icon,
                color: AgrisellColors.authGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter.label.toLowerCase()} orders',
              textAlign: TextAlign.center,
              style: SharedPresentationStyles.inkTitleExtraBold,
            ),
            const SizedBox(height: 6),
            const Text(
              'Checked-out harvests will appear here as their delivery status changes.',
              textAlign: TextAlign.center,
              style: SharedPresentationStyles.mutedCaptionMediumLoose,
            ),
          ],
        ),
      ),
    );
  }
}
