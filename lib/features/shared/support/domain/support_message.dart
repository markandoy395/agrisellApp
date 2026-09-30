enum SupportMessageSenderRole {
  user,
  support,
  system;

  String get dbValue => switch (this) {
    SupportMessageSenderRole.user => 'user',
    SupportMessageSenderRole.support => 'support',
    SupportMessageSenderRole.system => 'system',
  };

  bool get isFromCustomer => this == SupportMessageSenderRole.user;
  bool get isFromSupport => this == SupportMessageSenderRole.support;
  bool get isSystem => this == SupportMessageSenderRole.system;

  static SupportMessageSenderRole fromDb(String? value) {
    if (value == null) return SupportMessageSenderRole.user;
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'support' => SupportMessageSenderRole.support,
      'system' => SupportMessageSenderRole.system,
      _ => SupportMessageSenderRole.user,
    };
  }
}

class SupportMessage {
  const SupportMessage({
    required this.messageId,
    required this.ticketId,
    required this.senderRole,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.senderUserId,
    this.attachments = const [],
  });

  final int messageId;
  final int ticketId;
  final SupportMessageSenderRole senderRole;
  final String senderName;
  final int? senderUserId;
  final String body;
  final List<String> attachments;
  final DateTime createdAt;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    List<String> parsedAttachments = const [];
    if (rawAttachments is List) {
      parsedAttachments = rawAttachments.map((e) => e.toString()).toList();
    }

    return SupportMessage(
      messageId: (json['message_id'] as num?)?.toInt() ?? 0,
      ticketId: (json['ticket_id'] as num?)?.toInt() ?? 0,
      senderRole: SupportMessageSenderRole.fromDb(
        json['sender_role']?.toString(),
      ),
      senderName: json['sender_name']?.toString() ?? 'User',
      senderUserId: (json['sender_user_id'] as num?)?.toInt(),
      body: json['body']?.toString() ?? '',
      attachments: parsedAttachments,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'message_id': messageId,
    'ticket_id': ticketId,
    'sender_role': senderRole.dbValue,
    'sender_name': senderName,
    if (senderUserId != null) 'sender_user_id': senderUserId,
    'body': body,
    'attachments': attachments,
    'created_at': createdAt.toIso8601String(),
  };
}
