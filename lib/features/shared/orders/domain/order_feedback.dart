class OrderFeedback {
  const OrderFeedback({
    required this.rating,
    required this.comment,
    required this.submittedAt,
  });

  final int rating;
  final String comment;
  final DateTime submittedAt;

  bool get isValid => rating >= 1 && rating <= 5 && comment.length <= 500;
}
