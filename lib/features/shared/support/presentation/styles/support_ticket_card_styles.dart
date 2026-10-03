import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

abstract final class SupportTicketCardStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(6),
  );

  static const textStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.mutedText,
  );

  static const textStyle2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static BoxDecoration containerDecoration2(SupportTicket ticket) =>
      BoxDecoration(
        color: ticket.status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      );

  static TextStyle textStyle3(SupportTicket ticket) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: ticket.status.textColor,
  );

  static const textStyle4 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
    height: 1.3,
  );

  static const textStyle5 = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
    height: 1.35,
  );

  static BoxDecoration containerDecoration3(SupportTicket ticket) =>
      BoxDecoration(
        color: ticket.priority.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      );

  static TextStyle textStyle6(SupportTicket ticket) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: ticket.priority.textColor,
  );

  static final textStyle7 = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText.withValues(alpha: 0.8),
    fontWeight: FontWeight.w500,
  );
}
