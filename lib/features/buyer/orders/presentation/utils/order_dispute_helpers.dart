import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';

typedef SubmitOrderDispute =
    Future<void> Function({
      required String orderId,
      required OrderDisputeCategory category,
      required String reason,
      required OrderDisputeResolution requestedResolution,
    });

String? validateOrderDisputeReason(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Please describe the condition of the delivered produce.';
  }
  if (text.length < 10) {
    return 'Please provide more details (at least 10 characters).';
  }
  return null;
}

String orderDisputeErrorMessage(Object error) {
  final detail = error.toString().replaceFirst('Exception: ', '').trim();
  return detail.isEmpty ? 'Failed to submit dispute.' : detail;
}

String formatOrderDisputeDate(DateTime? dateTime) {
  if (dateTime == null) return 'Pending';
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = monthNames[dateTime.month - 1];
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : (dateTime.hour == 0 ? 12 : dateTime.hour);
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$month $day, ${dateTime.year} · $hour:$minute $period';
}
