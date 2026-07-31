import 'dart:async';

enum RiderConversationParty { seller, buyer, support }

extension RiderConversationPartyDetails on RiderConversationParty {
  String get label => switch (this) {
    RiderConversationParty.seller => 'Seller',
    RiderConversationParty.buyer => 'Buyer',
    RiderConversationParty.support => 'Support',
  };
}

class RiderConversation {
  const RiderConversation({
    required this.id,
    required this.participantLabel,
    required this.party,
    this.deliveryId,
    this.riderId,
    this.supportAuthorized = false,
    this.lastMessagePreview,
    this.lastActivity,
    this.unreadCount = 0,
  }) : assert(id != ''),
       assert(participantLabel != ''),
       assert(unreadCount >= 0);

  final String id;
  final String participantLabel;
  final RiderConversationParty party;
  final String? deliveryId;

  /// Server-owned participant identity; never use a phone number here.
  final String? riderId;
  final bool supportAuthorized;
  final String? lastMessagePreview;
  final DateTime? lastActivity;
  final int unreadCount;

  RiderConversation copyWith({
    String? lastMessagePreview,
    DateTime? lastActivity,
    int? unreadCount,
  }) => RiderConversation(
    id: id,
    participantLabel: participantLabel,
    party: party,
    deliveryId: deliveryId,
    riderId: riderId,
    supportAuthorized: supportAuthorized,
    lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    lastActivity: lastActivity ?? this.lastActivity,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}

enum RiderMessageSender { rider, participant, system }

enum RiderMessageKind { text, location, photo, deliveryUpdate, system }

enum RiderMessageDeliveryStatus { pending, sent, delivered, read, failed }

class RiderChatMessage {
  const RiderChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.kind,
    required this.sentAt,
    this.body = '',
    this.attachmentReference,
    this.failureReason,
    RiderMessageDeliveryStatus status = RiderMessageDeliveryStatus.sent,
    bool isPending = false,
  }) : assert(id != ''),
       assert(conversationId != ''),
       assert(kind != RiderMessageKind.text || body != ''),
       status = isPending ? RiderMessageDeliveryStatus.pending : status;

  final String id;
  final String conversationId;
  final RiderMessageSender sender;
  final RiderMessageKind kind;
  final DateTime sentAt;
  final String body;
  final String? attachmentReference;
  final String? failureReason;
  final RiderMessageDeliveryStatus status;

  bool get isPending => status == RiderMessageDeliveryStatus.pending;
  bool get isFailed => status == RiderMessageDeliveryStatus.failed;
}

class RiderMessageDraft {
  const RiderMessageDraft({
    required this.conversationId,
    this.body = '',
    this.kind = RiderMessageKind.text,
    this.attachmentReference,
    this.idempotencyKey,
  }) : assert(conversationId != ''),
       assert(kind != RiderMessageKind.text || body != '');

  final String conversationId;
  final String body;
  final RiderMessageKind kind;

  /// Opaque protected reference for a photo or delivery location.
  final String? attachmentReference;
  final String? idempotencyKey;
}

enum RiderCommunicationActionType {
  call,
  shareLocation,
  attachPhoto,
  contactSupport,
}

/// An action reference intentionally contains IDs only, never phone numbers,
/// email addresses, GPS coordinates, or media bytes.
class RiderCommunicationAction {
  const RiderCommunicationAction({
    required this.type,
    required this.conversationId,
    this.deliveryId,
  }) : assert(conversationId != '');

  final RiderCommunicationActionType type;
  final String conversationId;
  final String? deliveryId;
}

typedef RiderCommunicationActionCallback =
    FutureOr<void> Function(RiderCommunicationAction action);

/// Returns an opaque protected reference after capture by the host app.
typedef RiderCommunicationAttachmentCallback =
    FutureOr<String?> Function(RiderCommunicationAction action);

class RiderQuickReply {
  const RiderQuickReply({required this.label, required this.message});

  final String label;
  final String message;

  static const defaults = <RiderQuickReply>[
    RiderQuickReply(label: 'On my way', message: 'I am on the way.'),
    RiderQuickReply(
      label: 'Pickup arrived',
      message: 'I have arrived at the pickup location.',
    ),
    RiderQuickReply(
      label: 'Prepare product',
      message: 'Please prepare the product.',
    ),
    RiderQuickReply(
      label: 'Waiting pickup',
      message: 'I am waiting at the pickup location.',
    ),
    RiderQuickReply(
      label: 'Picked up',
      message: 'The product has been picked up.',
    ),
    RiderQuickReply(
      label: 'Near delivery',
      message: 'I am near the delivery location.',
    ),
    RiderQuickReply(label: 'Arrived', message: 'I have arrived.'),
    RiderQuickReply(
      label: 'Send code',
      message: 'Please send the confirmation code.',
    ),
    RiderQuickReply(
      label: 'Location help',
      message: 'I cannot find the location.',
    ),
    RiderQuickReply(label: 'Route delayed', message: 'The route is delayed.'),
    RiderQuickReply(
      label: 'Contact support',
      message: 'Please contact support.',
    ),
  ];
}
