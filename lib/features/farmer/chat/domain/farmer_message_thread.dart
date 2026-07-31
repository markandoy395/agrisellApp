class FarmerMessageThread {
  const FarmerMessageThread({
    required this.id,
    required this.buyerName,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.status,
    required this.type,
    required this.messages,
  });

  final String id;
  final String buyerName;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final String productName;
  final String productImage;
  final String quantity;
  final String price;
  final FarmerMessageStatus status;
  final FarmerMessageType type;
  final List<FarmerChatMessage> messages;

  bool get hasUnread => unreadCount > 0;
  bool get hasOrderContext => productName.isNotEmpty;

  String get initials {
    final trimmedName = buyerName.trim();
    if (trimmedName.isEmpty) {
      return '?';
    }

    final words = trimmedName.split(_whitespacePattern);
    if (words.length == 1) {
      return _initialFor(words.first);
    }

    return '${_initialFor(words.first)}${_initialFor(words.last)}';
  }

  String _initialFor(String value) {
    return value.isEmpty ? '?' : value[0].toUpperCase();
  }
}

final _whitespacePattern = RegExp(r'\s+');

class FarmerChatMessage {
  const FarmerChatMessage({
    required this.text,
    required this.isFarmer,
    required this.timeLabel,
  });

  final String text;
  final bool isFarmer;
  final String timeLabel;
}

enum FarmerMessageType { order, reserve }

enum FarmerMessageStatus { reserve, toShip, completed }

extension FarmerMessageStatusText on FarmerMessageStatus {
  String get listLabel {
    return switch (this) {
      FarmerMessageStatus.reserve => 'Reserve inquiry',
      FarmerMessageStatus.toShip => 'To Ship',
      FarmerMessageStatus.completed => 'Completed',
    };
  }

  String get chipLabel {
    return switch (this) {
      FarmerMessageStatus.reserve => 'Reserve',
      FarmerMessageStatus.toShip => 'To Ship',
      FarmerMessageStatus.completed => 'Completed',
    };
  }
}
