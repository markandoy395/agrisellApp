import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';

class InMemoryRiderWithdrawalStore {
  InMemoryRiderWithdrawalStore({
    Map<String, List<RiderWithdrawalMethod>> methodsByRider = const {},
    Map<String, List<RiderWithdrawalRequest>> requestsByRider = const {},
  })  : _methods = {
          for (final entry in methodsByRider.entries)
            entry.key: [...entry.value],
        },
        _requests = {
          for (final entry in requestsByRider.entries)
            entry.key: [...entry.value],
        };

  final Map<String, List<RiderWithdrawalMethod>> _methods;
  final Map<String, List<RiderWithdrawalRequest>> _requests;

  List<RiderWithdrawalMethod> fetchMethods(String riderId) {
    final list = _methods[riderId] ?? const [];
    return List.unmodifiable(list);
  }

  RiderWithdrawalMethod saveMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  }) {
    final current = _methods.putIfAbsent(riderId, () => []);
    if (method.isDefault) {
      for (var i = 0; i < current.length; i++) {
        current[i] = RiderWithdrawalMethod(
          methodId: current[i].methodId,
          payoutMethod: current[i].payoutMethod,
          accountName: current[i].accountName,
          accountNumber: current[i].accountNumber,
          bankName: current[i].bankName,
          isDefault: false,
          createdAt: current[i].createdAt,
        );
      }
    }
    final saved = RiderWithdrawalMethod(
      methodId: method.methodId.isNotEmpty
          ? method.methodId
          : 'wm-${DateTime.now().millisecondsSinceEpoch}',
      payoutMethod: method.payoutMethod,
      accountName: method.accountName,
      accountNumber: method.accountNumber,
      bankName: method.bankName,
      isDefault: method.isDefault,
      createdAt: DateTime.now(),
    );
    current.insert(0, saved);
    return saved;
  }

  void deleteMethod({required String riderId, required String methodId}) {
    _methods[riderId]?.removeWhere((m) => m.methodId == methodId);
  }

  RiderWithdrawalRequest submitRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  }) {
    final list = _requests.putIfAbsent(riderId, () => []);
    final saved = RiderWithdrawalRequest(
      requestId: request.requestId.isNotEmpty
          ? request.requestId
          : 'req-${DateTime.now().millisecondsSinceEpoch}',
      amount: request.amount,
      payoutMethod: request.payoutMethod,
      accountName: request.accountName,
      accountNumber: request.accountNumber,
      bankName: request.bankName,
      status: 'pending',
      notes: request.notes,
      createdAt: DateTime.now(),
    );
    list.insert(0, saved);
    return saved;
  }

  List<RiderWithdrawalRequest> fetchRequests(String riderId) {
    final list = _requests[riderId] ?? const [];
    return List.unmodifiable(list);
  }
}
