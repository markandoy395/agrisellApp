import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_earning.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';

enum RiderHistoryStatus { completed, cancelled, failed, returned, disputed }

enum RiderHistoryPaymentStatus { pending, paid, disputed }

extension RiderHistoryStatusDetails on RiderHistoryStatus {
  String get label => switch (this) {
    RiderHistoryStatus.completed => 'Completed',
    RiderHistoryStatus.cancelled => 'Cancelled',
    RiderHistoryStatus.failed => 'Failed',
    RiderHistoryStatus.returned => 'Returned',
    RiderHistoryStatus.disputed => 'Disputed',
  };
}

/// A completed or closed delivery record supplied by the rider history API.
class RiderDeliveryHistoryEntry {
  const RiderDeliveryHistoryEntry({
    required this.id,
    required this.orderNumber,
    required this.completedAt,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.productName,
    required this.quantityDescription,
    required this.deliveryFee,
    required this.status,
    this.customerRating,
    this.sellerName = '',
    this.buyerName = '',
    this.paymentStatus = RiderHistoryPaymentStatus.pending,
    this.proofTypes = const [],
    this.timeline = const [],
    this.deliveryNotes,
    this.recipientName,
    this.earningStatus = DeliveryEarningStatus.pending,
    this.earning,
    this.cashCollection,
    this.deliveryEvidence,
  }) : assert(id != ''),
       assert(orderNumber != ''),
       assert(deliveryFee >= 0),
       assert(
         customerRating == null || (customerRating >= 1 && customerRating <= 5),
       );

  final String id;
  final String orderNumber;
  final DateTime completedAt;
  final String pickupAddress;
  final String deliveryAddress;
  final String productName;
  final String quantityDescription;
  final double deliveryFee;
  final RiderHistoryStatus status;
  final double? customerRating;
  final String sellerName;
  final String buyerName;
  final RiderHistoryPaymentStatus paymentStatus;
  final List<DeliveryProofType> proofTypes;
  final List<DeliveryStatusEvent> timeline;
  final String? deliveryNotes;
  final String? recipientName;
  final DeliveryEarningStatus earningStatus;
  final DeliveryEarningBreakdown? earning;
  final CashCollectionRecord? cashCollection;
  final DeliveryProof? deliveryEvidence;

  bool get hasProof => proofTypes.isNotEmpty;
  bool get isEditable => false;

  factory RiderDeliveryHistoryEntry.fromCompletion(
    DeliveryCompletionRecord record,
  ) {
    DeliveryProof? evidence;
    for (final proof in record.request.proofs) {
      if (proof.type == DeliveryProofType.deliveryPhoto) {
        evidence = proof;
        break;
      }
    }
    return RiderDeliveryHistoryEntry(
      id: record.request.id,
      orderNumber: record.request.orderNumber,
      completedAt: record.completedAt,
      pickupAddress: record.request.pickupLocation.address,
      deliveryAddress: record.request.deliveryLocation.address,
      productName: record.request.productName,
      quantityDescription: record.request.quantityDescription,
      deliveryFee: record.earning?.netEarning ?? record.request.deliveryFee,
      status: RiderHistoryStatus.completed,
      sellerName: record.request.sellerName,
      buyerName: record.request.buyerName,
      paymentStatus: RiderHistoryPaymentStatus.pending,
      proofTypes: [for (final proof in record.request.proofs) proof.type],
      timeline: record.events,
      deliveryNotes: record.deliveryNotes,
      recipientName: record.recipientName,
      earningStatus: record.earningStatus,
      earning: record.earning,
      cashCollection: record.cashCollection,
      deliveryEvidence: evidence,
    );
  }

  bool matchesSearch(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return true;
    return orderNumber.toLowerCase().contains(value) ||
        productName.toLowerCase().contains(value) ||
        pickupAddress.toLowerCase().contains(value) ||
        deliveryAddress.toLowerCase().contains(value) ||
        sellerName.toLowerCase().contains(value) ||
        buyerName.toLowerCase().contains(value) ||
        paymentStatus.name.contains(value);
  }
}

class RiderHistoryQuery {
  const RiderHistoryQuery({
    this.status,
    this.dateRange,
    this.searchTerm = '',
    this.product,
    this.seller,
    this.buyer,
    this.pickupLocation,
    this.deliveryLocation,
    this.paymentStatus,
  });

  final RiderHistoryStatus? status;
  final RiderDateRange? dateRange;
  final String searchTerm;
  final String? product;
  final String? seller;
  final String? buyer;
  final String? pickupLocation;
  final String? deliveryLocation;
  final RiderHistoryPaymentStatus? paymentStatus;
}
