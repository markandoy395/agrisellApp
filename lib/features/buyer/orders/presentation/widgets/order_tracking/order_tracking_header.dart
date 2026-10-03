part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderTrackingHeader extends StatelessWidget {
  const _OrderTrackingHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final topPadding = (topInset > 0 ? topInset : 24.0) + 10;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        16,
      ),
      decoration: OrderTrackingHeaderStyles.containerDecoration,
      child: Row(
        children: [
          _HeaderCircleButton(
            semanticLabel: 'Go back',
            child: const Icon(
              Icons.arrow_back,
              color: AgrisellColors.surface,
              size: 24,
            ),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Tracking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrderTrackingHeaderStyles.orderTrackingText,
                ),
                SizedBox(height: 5),
                Text(
                  'Fresh orders waiting for delivery',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrderTrackingHeaderStyles
                      .freshOrdersWaitingForDeliveryText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: OrderTrackingHeaderStyles.containerDecoration2,
            child: const Icon(
              Icons.route_rounded,
              color: AgrisellColors.authGreen,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.semanticLabel,
    required this.child,
    required this.onTap,
  });

  final String semanticLabel;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 38,
        child: Material(
          color: AgrisellColors.surface.withValues(alpha: 0.26),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
