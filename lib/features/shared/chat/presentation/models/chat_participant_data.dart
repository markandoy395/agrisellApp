class ChatParticipantData {
  const ChatParticipantData({
    required this.name,
    required this.initials,
    required this.imageSemanticLabel,
    this.imageUrl,
    this.imageAsset,
  });

  final String name;
  final String initials;
  final String imageSemanticLabel;
  final String? imageUrl;
  final String? imageAsset;
}

class ChatConversationTileData {
  const ChatConversationTileData({
    required this.participant,
    required this.previewText,
    required this.timeLabel,
    required this.hasUnread,
    required this.semanticLabel,
  });

  final ChatParticipantData participant;
  final String previewText;
  final String timeLabel;
  final bool hasUnread;
  final String semanticLabel;
}
