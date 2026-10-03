part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isFilled = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isFilled;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 96;
        final padding = EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: 10,
        );
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
        final textStyle = SharedPresentationStyles.captionBold;
        final child = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        );

        if (isFilled) {
          return Tooltip(
            message: label,
            child: FilledButton(
              onPressed: onPressed,
              style: CompactOrderActionButtonStyles.filledButtonStyle(
                padding,
                textStyle,
                shape,
              ),
              child: child,
            ),
          );
        }

        return Tooltip(
          message: label,
          child: OutlinedButton(
            onPressed: onPressed,
            style: CompactOrderActionButtonStyles.outlinedButtonStyle(
              color,
              padding,
              textStyle,
              shape,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
