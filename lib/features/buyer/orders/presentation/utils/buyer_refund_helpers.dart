import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';

/// Formatting utilities and actions for buyer refund presentation.
abstract final class BuyerRefundHelpers {
  static const List<String> _monthNames = [
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

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final month = _monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year · $hour:$minute $period';
  }

  static void copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Refund reference copied to clipboard.'),
      ),
    );
  }
}
