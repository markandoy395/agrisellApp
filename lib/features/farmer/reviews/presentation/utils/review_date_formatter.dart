String formatFarmerReviewDate(DateTime date, {DateTime? now}) {
  final difference = (now ?? DateTime.now()).difference(date);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      final minutes = difference.inMinutes;
      return minutes <= 1 ? 'Just now' : '$minutes mins ago';
    }
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }
  return '${date.month}/${date.day}/${date.year}';
}
