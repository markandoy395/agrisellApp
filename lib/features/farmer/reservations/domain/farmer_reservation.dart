class FarmerReservation {
  const FarmerReservation({
    required this.id,
    required this.buyerName,
    required this.contactNumber,
    required this.address,
    required this.products,
    this.status = FarmerReservationStatus.reserved,
  });

  final String id;
  final String buyerName;
  final String contactNumber;
  final String address;
  final List<FarmerReservedProduct> products;
  final FarmerReservationStatus status;

  bool get canConfirm {
    return products.isNotEmpty && status == FarmerReservationStatus.reserved;
  }

  FarmerReservation copyWith({FarmerReservationStatus? status}) {
    return FarmerReservation(
      id: id,
      buyerName: buyerName,
      contactNumber: contactNumber,
      address: address,
      products: products,
      status: status ?? this.status,
    );
  }
}

class FarmerReservedProduct {
  const FarmerReservedProduct({
    required this.name,
    required this.price,
    required this.quantity,
    required this.harvestDate,
    required this.deliverDate,
    required this.image,
  });

  final String name;
  final String price;
  final String quantity;
  final String harvestDate;
  final String deliverDate;
  final String image;
}

enum FarmerReservationStatus { reserved, toShip }
