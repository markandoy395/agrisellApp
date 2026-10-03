import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';

enum FarmerPayoutFilter { all, paid, pending, failed }

extension FarmerPayoutFiltering on FarmerPayoutFilter {
  List<FarmerPayout> filterPayouts(List<FarmerPayout> payouts) {
    return switch (this) {
      FarmerPayoutFilter.all => payouts,
      FarmerPayoutFilter.paid =>
        payouts.where((p) => p.isPaid).toList(growable: false),
      FarmerPayoutFilter.pending =>
        payouts
            .where(
              (p) => p.isApproved || p.status == FarmerPayoutStatus.pending,
            )
            .toList(growable: false),
      FarmerPayoutFilter.failed =>
        payouts.where((p) => p.isFailed).toList(growable: false),
    };
  }

  List<FarmerCashOutRequest> filterCashOutRequests(
    List<FarmerCashOutRequest> requests,
  ) {
    return switch (this) {
      FarmerPayoutFilter.all => requests,
      FarmerPayoutFilter.paid =>
        requests.where((r) => r.isPaid).toList(growable: false),
      FarmerPayoutFilter.pending =>
        requests
            .where((r) => r.isPending || r.isApproved)
            .toList(growable: false),
      FarmerPayoutFilter.failed =>
        requests.where((r) => r.isRejected).toList(growable: false),
    };
  }
}
