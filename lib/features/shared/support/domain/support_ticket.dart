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

class SupportTicket {
  const SupportTicket({
    required this.ticketId,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.userRole,
    this.assignedAdmin,
    this.resolutionNotes,
    this.orderId,
    this.deliveryId,
    this.resolvedAt,
  });

  final int ticketId;
  final String ticketNumber;
  final String subject;
  final SupportTicketCategory category;
  final SupportTicketStatus status;
  final SupportTicketPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final String? userRole;
  final String? assignedAdmin;
  final String? resolutionNotes;
  final int? orderId;
  final int? deliveryId;
  final DateTime? resolvedAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: (json['ticket_id'] as num?)?.toInt() ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: SupportTicketCategory.fromDb(json['category']?.toString()),
      status: SupportTicketStatus.fromDb(json['status']?.toString()),
      priority: SupportTicketPriority.fromDb(json['priority']?.toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
      lastMessage: json['last_message']?.toString(),
      userRole: json['user_role']?.toString(),
      assignedAdmin: json['assigned_admin']?.toString(),
      resolutionNotes: json['resolution_notes']?.toString(),
      orderId: (json['order_id'] as num?)?.toInt(),
      deliveryId: (json['delivery_id'] as num?)?.toInt(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'].toString())?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'ticket_id': ticketId,
    'ticket_number': ticketNumber,
    'subject': subject,
    'category': category.dbValue,
    'status': status.dbValue,
    'priority': priority.dbValue,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (lastMessage != null) 'last_message': lastMessage,
    if (userRole != null) 'user_role': userRole,
    if (assignedAdmin != null) 'assigned_admin': assignedAdmin,
    if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
    if (orderId != null) 'order_id': orderId,
    if (deliveryId != null) 'delivery_id': deliveryId,
    if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
  };

  SupportTicket copyWith({
    int? ticketId,
    String? ticketNumber,
    String? subject,
    SupportTicketCategory? category,
    SupportTicketStatus? status,
    SupportTicketPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    String? userRole,
    String? assignedAdmin,
    String? resolutionNotes,
    int? orderId,
    int? deliveryId,
    DateTime? resolvedAt,
  }) {
    return SupportTicket(
      ticketId: ticketId ?? this.ticketId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      userRole: userRole ?? this.userRole,
      assignedAdmin: assignedAdmin ?? this.assignedAdmin,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      orderId: orderId ?? this.orderId,
      deliveryId: deliveryId ?? this.deliveryId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
