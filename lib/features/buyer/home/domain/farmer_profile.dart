class FarmerProfile {
  const FarmerProfile({
    required this.farmId,
    required this.name,
    required this.location,
    required this.rating,
    required this.coverImage,
    required this.products,
    this.imageUrl,
    this.coverImageUrl,
    this.followerCount = 0,
    this.isFollowing = false,
  });

  final int farmId;
  final String name;
  final String location;
  final double rating;
  final String coverImage;
  final List<ProductAvailability> products;
  final String? imageUrl;
  final String? coverImageUrl;
  final int followerCount;
  final bool isFollowing;

  FarmerProfile copyWith({int? followerCount, bool? isFollowing}) {
    return FarmerProfile(
      farmId: farmId,
      name: name,
      location: location,
      rating: rating,
      coverImage: coverImage,
      products: products,
      imageUrl: imageUrl,
      coverImageUrl: coverImageUrl,
      followerCount: followerCount ?? this.followerCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}

class ProductAvailability {
  const ProductAvailability({required this.name, required this.isAvailable});

  final String name;
  final bool isAvailable;
}
