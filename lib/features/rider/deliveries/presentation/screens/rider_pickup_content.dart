part of 'rider_pickup_confirmation_screen.dart';

extension _PickupContent on _RiderPickupConfirmationScreenState {
  Widget _buildPickup(BuildContext context) {
    final config = _configuration;
    return RiderSafeScaffold(
      backgroundColor: RiderPickupDesignStyles.background,
      body: Column(
        children: [
          const RiderPickupHeader(),
          Expanded(
            child: config == null
                ? Center(
                    child: _error == null
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              _error!,
                              style: RiderPickupDesignStyles.error,
                            ),
                          ),
                  )
                : ListView(
                    key: PageStorageKey('pickup-${widget.request.id}'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    children: [
                      _summary(),
                      if (_problemSaved) ...[
                        const SizedBox(height: 14),
                        RiderPickupFeedback(
                          onDismiss: () => _setProblemSaved(false),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _methods(config),
                      const SizedBox(height: 16),
                      _checklist(),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        RiderPickupValidationFeedback(
                          message: _error!,
                          issues: _validationIssues,
                        ),
                      ],
                    ],
                  ),
          ),
          if (config != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: _action(config),
            ),
        ],
      ),
    );
  }
}
