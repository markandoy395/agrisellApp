part of 'rider_delivery_request_card.dart';

class _RiderDeliveryRequestCardState extends State<RiderDeliveryRequestCard> {
  bool _acceptanceOpen = false;

  @override
  Widget build(BuildContext context) => RiderDeliveryRequestCardContent(
    card: widget,
    acceptanceOpen: _acceptanceOpen,
    onAccept: _accept,
  );

  Future<void> _accept() async {
    if (_acceptanceOpen || widget.onAccept == null) return;
    setState(() => _acceptanceOpen = true);
    final result = await showRiderAcceptanceDialog(
      context,
      request: widget.request,
      onConfirm: widget.onAccept!,
    );
    if (!mounted) return;
    setState(() => _acceptanceOpen = false);
    if (result?.isSuccess != true) return;
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(content: Text('Delivery accepted successfully.')),
    );
    widget.onAccepted?.call(result!.receipt!.request);
  }
}
