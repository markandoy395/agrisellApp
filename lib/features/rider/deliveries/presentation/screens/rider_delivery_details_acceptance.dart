part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsAcceptance on _RiderDeliveryDetailsScreenState {
  Future<void> _accept() async {
    if (_acceptanceOpen) return;
    _applyAcceptanceState(isOpen: true);
    final result = await showRiderAcceptanceDialog(
      context,
      request: _request,
      onConfirm: () => widget.controller.accept(
        requestId: _request.id,
        riderId: widget.riderId,
      ),
    );
    if (!mounted) return;
    _applyAcceptanceState(isOpen: false);
    if (result?.isSuccess != true) return;
    _applyAcceptanceState(isOpen: false, request: result!.receipt!.request);
    _showMessage('Delivery accepted successfully.');
  }

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
