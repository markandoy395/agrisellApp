import 'package:agresell_app/features/shared/chat/domain/marketplace_chat_format.dart';

export 'package:agresell_app/features/shared/chat/domain/marketplace_chat_format.dart';

enum MarketplaceActorRole { buyer, farmer }

enum MarketplaceMessageState { sending, sent, failed }

class MarketplaceConversationSeed {
  const MarketplaceConversationSeed({
    required this.sellerName,
    this.commodityId,
    this.farmId,
    this.clientOrderId,
    this.productName,
  }) : assert(commodityId != null || farmId != null);

  final String sellerName;
  final String? commodityId;
  final int? farmId;
  final String? clientOrderId;
  final String? productName;
}

class MarketplaceConversation {
  const MarketplaceConversation({
    required this.id,
    required this.buyerName,
    required this.farmerName,
    required this.farmName,
    required this.location,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
    this.buyerImageUrl,
    this.farmerImageUrl,
    this.commodityId,
    this.productName,
    this.productImageUrl,
    this.unitType,
    this.orderReference,
    this.orderStatus,
    this.quantity,
    this.unitPrice,
  });

  factory MarketplaceConversation.fromJson(Map<String, Object?> json) {
    return MarketplaceConversation(
      id: _text(json['conversation_id']),
      buyerName: _text(json['buyer_name'], 'Buyer'),
      buyerImageUrl: _optionalText(json['buyer_image_url']),
      farmerName: _text(json['farmer_name'], 'Farmer'),
      farmerImageUrl: _optionalText(json['farmer_image_url']),
      farmName: _text(json['farm_name'], 'Farm'),
      location: _text(json['farm_location'], 'Location unavailable'),
      commodityId: _optionalText(json['commodity_id']),
      productName: _optionalText(json['product_name']),
      productImageUrl: _optionalText(json['product_image_url']),
      unitType: _optionalText(json['unit_type']),
      orderReference: _optionalText(json['order_reference']),
      orderStatus: _optionalText(json['order_status']),
      quantity: _number(json['quantity']),
      unitPrice: _number(json['unit_price']),
      lastMessage: _text(json['last_message']),
      updatedAt: _date(json['last_message_at']),
      unreadCount: _integer(json['unread_count']),
    );
  }

  final String id;
  final String buyerName;
  final String? buyerImageUrl;
  final String farmerName;
  final String? farmerImageUrl;
  final String farmName;
  final String location;
  final String? commodityId;
  final String? productName;
  final String? productImageUrl;
  final String? unitType;
  final String? orderReference;
  final String? orderStatus;
  final double? quantity;
  final double? unitPrice;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;
  bool get hasOrderContext => orderReference != null;
  bool get hasProductContext => productName != null;
  String get timeLabel => marketplaceTimeLabel(updatedAt);
  String get initials => marketplaceInitials(buyerName);
  String get previewText => lastMessage.isEmpty
      ? 'Start a conversation about ${productName ?? farmName}.'
      : lastMessage;
  String get contextLabel => orderReference == null
      ? productName ?? farmName
      : '${productName ?? 'Order'} • $orderStatusLabel';
  String get orderStatusLabel {
    final status = (orderStatus ?? '').replaceAll('_', ' ').trim();
    if (status.isEmpty) return hasOrderContext ? 'Order' : 'Product inquiry';
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  MarketplaceConversation copyWith({
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) => MarketplaceConversation(
    id: id,
    buyerName: buyerName,
    buyerImageUrl: buyerImageUrl,
    farmerName: farmerName,
    farmerImageUrl: farmerImageUrl,
    farmName: farmName,
    location: location,
    commodityId: commodityId,
    productName: productName,
    productImageUrl: productImageUrl,
    unitType: unitType,
    orderReference: orderReference,
    orderStatus: orderStatus,
    quantity: quantity,
    unitPrice: unitPrice,
    lastMessage: lastMessage ?? this.lastMessage,
    updatedAt: updatedAt ?? this.updatedAt,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}

class MarketplaceMessage {
  const MarketplaceMessage({
    required this.id,
    required this.senderRole,
    required this.text,
    required this.sentAt,
    this.state = MarketplaceMessageState.sent,
  });

  factory MarketplaceMessage.fromJson(Map<String, Object?> json) {
    return MarketplaceMessage(
      id: _text(json['message_id']),
      senderRole: _text(json['sender_role']) == 'farmer'
          ? MarketplaceActorRole.farmer
          : MarketplaceActorRole.buyer,
      text: _text(json['body']),
      sentAt: _date(json['sent_at']),
    );
  }

  final String id;
  final MarketplaceActorRole senderRole;
  final String text;
  final DateTime sentAt;
  final MarketplaceMessageState state;

  bool get isBuyer => senderRole == MarketplaceActorRole.buyer;
  bool get isFarmer => senderRole == MarketplaceActorRole.farmer;
  String get timeLabel => marketplaceTimeLabel(sentAt);

  MarketplaceMessage copyWith({MarketplaceMessageState? state}) =>
      MarketplaceMessage(
        id: id,
        senderRole: senderRole,
        text: text,
        sentAt: sentAt,
        state: state ?? this.state,
      );
}

String _text(Object? value, [String fallback = '']) =>
    value?.toString().trim().isNotEmpty == true
    ? value.toString().trim()
    : fallback;
String? _optionalText(Object? value) {
  final result = _text(value);
  return result.isEmpty ? null : result;
}

double? _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(_text(value));
int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(_text(value)) ?? 0;
DateTime _date(Object? value) =>
    DateTime.tryParse(_text(value)) ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
