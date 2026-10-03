part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderFeedbackStarSelector extends StatelessWidget {
  const _OrderFeedbackStarSelector({
    required this.rating,
    required this.onRatingChanged,
    required this.enabled,
    this.isRider = false,
  });

  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final bool enabled;
  final bool isRider;

  @override
  Widget build(BuildContext context) {
    final ratingType = isRider ? 'rider rating' : 'rating';
    return Semantics(
      label: 'Selected $ratingType: $rating out of 5 stars',
      child: Row(
        children: [
          for (var value = 1; value <= 5; value++)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: '$value star $ratingType',
              onPressed: enabled ? () => onRatingChanged?.call(value) : null,
              icon: Icon(
                value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AgrisellColors.accentOrange,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
