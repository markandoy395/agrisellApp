part of 'rider_analytics_controller.dart';

extension RiderAnalyticsWallet on RiderAnalyticsController {
  Future<void> loadWithdrawalMethods({required String riderId}) async {
    final ticket = _scope.begin('methods');
    try {
      final values = await _repository.fetchWithdrawalMethods(riderId: riderId);
      if (!ticket.isCurrent) return;
      _withdrawalMethods = values;
      _notify();
    } catch (_) {}
  }

  Future<void> loadWallet({required String riderId}) async {
    final ticket = _scope.begin('wallet');
    wallet = null;
    walletError = null;
    try {
      final repository = _repository;
      if (repository is! RiderWalletRepository) {
        throw StateError('Wallet unavailable');
      }
      final value = await (repository as RiderWalletRepository).fetchWallet();
      if (!ticket.isCurrent) return;
      final requests = await _repository.fetchWithdrawalRequests(
        riderId: riderId,
      );
      if (!ticket.isCurrent) return;
      wallet = value;
      _withdrawalRequests = requests;
    } catch (_) {
      if (!ticket.isCurrent) return;
      wallet = null;
      _withdrawalRequests = const [];
      walletError = 'Cash-out balance could not be verified. Please retry.';
    }
    _notify();
  }

  Future<RiderWithdrawalMethod> saveWithdrawalMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  }) => _operations.run((riderId, 'saveMethod'), () async {
    final ticket = _scope.begin('saveMethod');
    final saved = await _repository.saveWithdrawalMethod(
      riderId: riderId,
      method: method,
    );
    if (ticket.isCurrent) await loadWithdrawalMethods(riderId: riderId);
    return saved;
  });

  Future<void> deleteWithdrawalMethod({
    required String riderId,
    required String methodId,
  }) => _operations.run((riderId, 'deleteMethod', methodId), () async {
    final ticket = _scope.begin(('deleteMethod', methodId));
    await _repository.deleteWithdrawalMethod(
      riderId: riderId,
      methodId: methodId,
    );
    if (ticket.isCurrent) await loadWithdrawalMethods(riderId: riderId);
  });

  Future<RiderWithdrawalRequest> submitWithdrawalRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  }) => _operations.run((riderId, 'withdraw'), () async {
    final ticket = _scope.begin('withdraw');
    final saved = await _repository.submitWithdrawalRequest(
      riderId: riderId,
      request: request,
    );
    if (ticket.isCurrent) await loadWithdrawalRequests(riderId: riderId);
    return saved;
  });

  Future<void> loadWithdrawalRequests({required String riderId}) async {
    final ticket = _scope.begin('withdrawals');
    try {
      final values = await _repository.fetchWithdrawalRequests(
        riderId: riderId,
      );
      if (!ticket.isCurrent) return;
      _withdrawalRequests = values;
      _notify();
    } catch (_) {}
  }
}
