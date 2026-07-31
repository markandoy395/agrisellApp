part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryRequests on InMemoryRiderDeliveryRepository {
  Future<RiderRequestPage> _fetchNearbyRequests(RiderRequestQuery query) async {
    final now = _clock();
    final search = query.searchText.trim().toLowerCase();
    final eligible = _requests.values.where((request) {
      if (riderRequestRejection(
            request,
            query.matching,
            at: now,
            requireCurrentGps: !query.matching.usesRegisteredLocationEstimate,
          ) !=
          null) {
        return false;
      }
      final rider = _riderStates[query.matching.riderId];
      if (rider != null &&
          _batchAcceptanceRejection(candidate: request, rider: rider) != null) {
        return false;
      }
      if (!query.filters.allows(
        request,
        pickupDistanceKm: query.matching.pickupDistanceKm(request),
      )) {
        return false;
      }
      if (search.isEmpty) return true;
      return <String>[
        request.productName,
        request.productCategory,
        request.pickupLocation.address,
        request.deliveryLocation.address,
        request.sellerName,
        request.orderNumber,
      ].any((value) => value.toLowerCase().contains(search));
    }).toList();
    sortRiderRequests(
      eligible,
      query.sort,
      pickupDistanceKm: query.matching.pickupDistanceKm,
    );
    final offset = int.tryParse(query.cursor ?? '') ?? 0;
    final end = (offset + query.pageSize).clamp(0, eligible.length);
    if (offset >= eligible.length) {
      return const RiderRequestPage(items: []);
    }
    return RiderRequestPage(
      items: List<DeliveryRequest>.unmodifiable(eligible.sublist(offset, end)),
      nextCursor: end < eligible.length ? '$end' : null,
    );
  }
}
