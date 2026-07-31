part of 'farmer_shop_screen.dart';

extension _FarmerShopScreenActions on _FarmerShopScreenState {
  Future<void> _loadFollowState() async {
    try {
      await _followController.refresh(widget.farmer);
    } on Object {
      // Keep the directory-provided state when a refresh is unavailable.
    }
  }

  void _openChat() {
    unawaited(
      BuyerConversationLauncher.open(
        context,
        sellerName: widget.farmer.name,
        farmId: widget.farmer.farmId,
      ),
    );
  }
}
