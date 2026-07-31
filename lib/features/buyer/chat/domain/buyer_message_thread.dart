class BuyerMessageThread {
  const BuyerMessageThread({
    required this.id,
    required this.farmerName,
    required this.location,
    required this.farmerImage,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.productName,
    required this.productImage,
    required this.messages,
  });

  final String id;
  final String farmerName;
  final String location;
  final String farmerImage;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final String productName;
  final String productImage;
  final List<BuyerChatMessage> messages;

  bool get hasUnread => unreadCount > 0;
}

class BuyerChatMessage {
  const BuyerChatMessage({
    required this.text,
    required this.isBuyer,
    required this.timeLabel,
  });

  final String text;
  final bool isBuyer;
  final String timeLabel;
}
