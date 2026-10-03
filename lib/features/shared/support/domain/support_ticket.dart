import 'package:agresell_app/features/shared/support/domain/support_ticket_enums.dart';

export 'package:agresell_app/features/shared/support/domain/support_ticket_enums.dart';

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
