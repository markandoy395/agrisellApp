import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

enum SupportTicketCategory {
  order,
  delivery,
  payment,
  account,
  safety,
  general;

  String get dbValue => switch (this) {
    SupportTicketCategory.order => 'order',
    SupportTicketCategory.delivery => 'delivery',
    SupportTicketCategory.payment => 'payment',
    SupportTicketCategory.account => 'account',
    SupportTicketCategory.safety => 'safety',
    SupportTicketCategory.general => 'general',
  };

  String get label => switch (this) {
    SupportTicketCategory.order => 'Order Issue',
    SupportTicketCategory.delivery => 'Delivery Problem',
    SupportTicketCategory.payment => 'Payment & Refund',
    SupportTicketCategory.account => 'Account & Login',
    SupportTicketCategory.safety => 'Safety & Security',
    SupportTicketCategory.general => 'General Inquiry',
  };

  IconData get icon => switch (this) {
    SupportTicketCategory.order => Icons.shopping_bag_outlined,
    SupportTicketCategory.delivery => Icons.local_shipping_outlined,
    SupportTicketCategory.payment => Icons.payments_outlined,
    SupportTicketCategory.account => Icons.manage_accounts_outlined,
    SupportTicketCategory.safety => Icons.shield_outlined,
    SupportTicketCategory.general => Icons.help_outline_rounded,
  };

  static SupportTicketCategory fromDb(String? value) {
    if (value == null) return SupportTicketCategory.general;
    final normalized = value.trim().toLowerCase();
    for (final category in SupportTicketCategory.values) {
      if (category.dbValue == normalized || category.name == normalized) {
        return category;
      }
    }
    return SupportTicketCategory.general;
  }
}

enum SupportTicketPriority {
  low,
  medium,
  high,
  urgent;

  String get dbValue => switch (this) {
    SupportTicketPriority.low => 'low',
    SupportTicketPriority.medium => 'medium',
    SupportTicketPriority.high => 'high',
    SupportTicketPriority.urgent => 'urgent',
  };

  String get label => switch (this) {
    SupportTicketPriority.low => 'Low',
    SupportTicketPriority.medium => 'Medium',
    SupportTicketPriority.high => 'High',
    SupportTicketPriority.urgent => 'Urgent',
  };

  Color get textColor => switch (this) {
    SupportTicketPriority.low => AgrisellColors.mutedText,
    SupportTicketPriority.medium => AgrisellColors.statusBlueText,
    SupportTicketPriority.high => AgrisellColors.statusOrangeText,
    SupportTicketPriority.urgent => AgrisellColors.statusRedText,
  };

  Color get backgroundColor => switch (this) {
    SupportTicketPriority.low => AgrisellColors.searchBackground,
    SupportTicketPriority.medium => AgrisellColors.statusBlueBackground,
    SupportTicketPriority.high => AgrisellColors.statusOrangeBackground,
    SupportTicketPriority.urgent => AgrisellColors.statusRedBackground,
  };

  static SupportTicketPriority fromDb(String? value) {
    if (value == null) return SupportTicketPriority.medium;
    final normalized = value.trim().toLowerCase();
    for (final priority in SupportTicketPriority.values) {
      if (priority.dbValue == normalized || priority.name == normalized) {
        return priority;
      }
    }
    return SupportTicketPriority.medium;
  }
}

enum SupportTicketStatus {
  open,
  inProgress,
  waitingOnCustomer,
  resolved,
  closed;

  String get dbValue => switch (this) {
    SupportTicketStatus.open => 'open',
    SupportTicketStatus.inProgress => 'in_progress',
    SupportTicketStatus.waitingOnCustomer => 'waiting_on_customer',
    SupportTicketStatus.resolved => 'resolved',
    SupportTicketStatus.closed => 'closed',
  };

  String get label => switch (this) {
    SupportTicketStatus.open => 'Open',
    SupportTicketStatus.inProgress => 'In Progress',
    SupportTicketStatus.waitingOnCustomer => 'Waiting on You',
    SupportTicketStatus.resolved => 'Resolved',
    SupportTicketStatus.closed => 'Closed',
  };

  bool get isOpen =>
      this == SupportTicketStatus.open ||
      this == SupportTicketStatus.inProgress ||
      this == SupportTicketStatus.waitingOnCustomer;

  bool get isTerminal =>
      this == SupportTicketStatus.resolved || this == SupportTicketStatus.closed;

  Color get textColor => switch (this) {
    SupportTicketStatus.open => AgrisellColors.statusBlueText,
    SupportTicketStatus.inProgress => AgrisellColors.statusOrangeText,
    SupportTicketStatus.waitingOnCustomer => AgrisellColors.statusPurpleText,
    SupportTicketStatus.resolved => AgrisellColors.statusGreenText,
    SupportTicketStatus.closed => AgrisellColors.mutedText,
  };

  Color get backgroundColor => switch (this) {
    SupportTicketStatus.open => AgrisellColors.statusBlueBackground,
    SupportTicketStatus.inProgress => AgrisellColors.statusOrangeBackground,
    SupportTicketStatus.waitingOnCustomer =>
      AgrisellColors.statusPurpleBackground,
    SupportTicketStatus.resolved => AgrisellColors.statusGreenBackground,
    SupportTicketStatus.closed => AgrisellColors.searchBackground,
  };

  static SupportTicketStatus fromDb(String? value) {
    if (value == null) return SupportTicketStatus.open;
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'open' => SupportTicketStatus.open,
      'in_progress' || 'inprogress' => SupportTicketStatus.inProgress,
      'waiting_on_customer' ||
      'waitingoncustomer' => SupportTicketStatus.waitingOnCustomer,
      'resolved' => SupportTicketStatus.resolved,
      'closed' => SupportTicketStatus.closed,
      _ => SupportTicketStatus.open,
    };
  }
}
