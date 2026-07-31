import 'rider_communication_models.dart';

/// Delivery access is supplied by the active-delivery/history owner, not by
/// contact information embedded in a conversation.
class RiderConversationAccess {
  const RiderConversationAccess({
    this.activeDeliveryIds = const {},
    this.historyDeliveryIds = const {},
    this.supportAuthorized = false,
  });

  final Set<String> activeDeliveryIds;
  final Set<String> historyDeliveryIds;
  final bool supportAuthorized;

  bool allows(RiderConversation conversation, String riderId) {
    if (conversation.riderId != null && conversation.riderId != riderId) {
      return false;
    }
    if (conversation.party == RiderConversationParty.support) {
      return supportAuthorized && conversation.supportAuthorized;
    }
    final deliveryId = conversation.deliveryId;
    return deliveryId != null &&
        (activeDeliveryIds.contains(deliveryId) ||
            historyDeliveryIds.contains(deliveryId));
  }
}
