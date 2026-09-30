part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderFeedbackSheet extends StatefulWidget {
  const _OrderFeedbackSheet({
    required this.order,
    required this.item,
    required this.onSubmit,
  });

  final PlacedOrder order;
  final PlacedOrderItem item;
  final Future<void> Function(
    int rating,
    String comment,
    int? riderRating,
    String riderComment,
  )
  onSubmit;

  @override
  State<_OrderFeedbackSheet> createState() => _OrderFeedbackSheetState();
}

class _OrderFeedbackSheetState extends State<_OrderFeedbackSheet> {
  final _commentController = TextEditingController();
  final _riderCommentController = TextEditingController();
  var _rating = 5;
  var _riderRating = 5;
  var _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    _riderCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canRateProduct = widget.order.canReviewProduct(widget.item.productId);
    final canRateRider =
        widget.order.deliveryId != null && !widget.order.riderRated;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FeedbackProductHeader(item: widget.item),
            const SizedBox(height: 15),
            Text(
              canRateProduct
                  ? 'How was this product?'
                  : 'How was your delivery?',
              style: TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Your feedback helps buyers and supports trusted farmers.',
              style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 7),
            if (canRateProduct) ...[
              Semantics(
                label: 'Selected rating: $_rating out of 5 stars',
                child: Row(
                  children: [
                    for (var value = 1; value <= 5; value++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: '$value star rating',
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _rating = value),
                        icon: Icon(
                          value <= _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AgrisellColors.accentOrange,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('order-feedback-comment'),
                controller: _commentController,
                enabled: !_submitting,
                minLines: 3,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Comment (optional)',
                  hintText: 'Freshness, packaging, and seller service',
                  filled: true,
                  fillColor: AgrisellColors.searchBackground,
                  border: _feedbackBorder(AgrisellColors.borderLine),
                  enabledBorder: _feedbackBorder(AgrisellColors.borderLine),
                  focusedBorder: _feedbackBorder(AgrisellColors.authGreen),
                ),
              ),
            ],
            if (canRateRider) ...[
              const SizedBox(height: 10),
              const Divider(color: AgrisellColors.borderLine),
              const Text(
                'Rate your rider',
                style: TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Semantics(
                label: 'Selected rider rating: $_riderRating out of 5 stars',
                child: Row(
                  children: [
                    for (var value = 1; value <= 5; value++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: '$value star rider rating',
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _riderRating = value),
                        icon: Icon(
                          value <= _riderRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AgrisellColors.accentOrange,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ),
              TextField(
                key: const ValueKey('rider-feedback-comment'),
                controller: _riderCommentController,
                enabled: !_submitting,
                minLines: 2,
                maxLines: 3,
                maxLength: 500,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Rider comment (optional)',
                  hintText: 'Delivery care, communication, and service',
                  filled: true,
                  fillColor: AgrisellColors.searchBackground,
                  border: _feedbackBorder(AgrisellColors.borderLine),
                  enabledBorder: _feedbackBorder(AgrisellColors.borderLine),
                  focusedBorder: _feedbackBorder(AgrisellColors.authGreen),
                ),
              ),
            ],
            if (_error case final message?) ...[
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  color: AgrisellColors.statusRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton.icon(
                key: const ValueKey('submit-order-feedback'),
                onPressed: _submitting ? null : _submitFeedback,
                style: FilledButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AgrisellColors.surface,
                        ),
                      )
                    : const Icon(Icons.rate_review_outlined, size: 16),
                label: Text(
                  _submitting ? 'Saving feedback…' : 'Submit feedback',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _feedbackBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: color),
  );

  Future<void> _submitFeedback() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        _rating,
        _commentController.text,
        widget.order.deliveryId != null && !widget.order.riderRated
            ? _riderRating
            : null,
        _riderCommentController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showAppSnackBar(
        const SnackBar(content: Text('Feedback saved. Thank you!')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        final detail = error.toString().replaceFirst('Exception: ', '').trim();
        _error = detail.isEmpty
            ? 'Feedback could not be saved. Please try again.'
            : detail;
      });
    }
  }
}
