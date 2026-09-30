import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';

abstract class FarmerPayoutRepository {
  Future<List<FarmerPayout>> loadPayouts();
  Future<List<FarmerCashOutRequest>> loadCashOutRequests();
  Future<FarmerCashOutRequest> submitCashOutRequest(FarmerCashOutRequest request);
}

class InMemoryFarmerPayoutRepository implements FarmerPayoutRepository {
  InMemoryFarmerPayoutRepository([
    List<FarmerPayout>? initialPayouts,
    List<FarmerCashOutRequest>? initialRequests,
  ])  : _payouts = List.of(initialPayouts ?? const []),
        _cashOutRequests = List.of(initialRequests ?? const []);

  final List<FarmerPayout> _payouts;
  final List<FarmerCashOutRequest> _cashOutRequests;

  void setPayouts(List<FarmerPayout> payouts) {
    _payouts
      ..clear()
      ..addAll(payouts);
  }

  void setCashOutRequests(List<FarmerCashOutRequest> requests) {
    _cashOutRequests
      ..clear()
      ..addAll(requests);
  }

  @override
  Future<List<FarmerPayout>> loadPayouts() async => List.unmodifiable(_payouts);

  @override
  Future<List<FarmerCashOutRequest>> loadCashOutRequests() async =>
      List.unmodifiable(_cashOutRequests);

  @override
  Future<FarmerCashOutRequest> submitCashOutRequest(
      FarmerCashOutRequest request) async {
    final created = FarmerCashOutRequest(
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
    _cashOutRequests.insert(0, created);
    return created;
  }
}
