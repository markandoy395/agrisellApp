import 'package:flutter/material.dart';
import 'create_support_ticket_styles.dart';

abstract final class CreateSupportTicketSelectionStyles {
  static BoxDecoration category(bool selected) => BoxDecoration(
    color: selected ? null : Colors.white,
    gradient: selected ? CreateSupportTicketStyles.greenGradient : null,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: selected ? Colors.transparent : const Color(0xFFF0F3F2),
    ),
    boxShadow: [
      BoxShadow(
        color: selected ? const Color(0x14148548) : const Color(0x0609252B),
        blurRadius: 18,
        offset: const Offset(0, 5),
      ),
    ],
  );
  static BoxDecoration priority(bool selected) => BoxDecoration(
    color: selected ? const Color(0xFFEAF6EE) : Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: selected
          ? CreateSupportTicketStyles.primaryGreen
          : const Color(0xFFF0F3F2),
      width: selected ? 1.3 : 1,
    ),
  );
  static TextStyle categoryLabel(bool selected) => TextStyle(
    color: categoryColor(selected),
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static Color categoryColor(bool selected) =>
      selected ? Colors.white : CreateSupportTicketStyles.headingTextColor;
  static TextStyle priorityLabel(bool selected) => TextStyle(
    color: selected
        ? CreateSupportTicketStyles.primaryGreen
        : const Color(0xFF626B7A),
    fontSize: 14,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
  );
  static final radius = BorderRadius.circular(16);
}
