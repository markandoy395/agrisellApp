import 'package:agresell_app/features/buyer/home/data/farmer_directory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a marketplace farmer directory row', () {
    final farmer = FarmerDirectoryRepository.farmerFromRow({
      'farm_id': 18,
      'farmer_name': 'Maria Santos',
      'farm_location': 'Bukidnon',
      'profile_image_url': 'https://example.com/maria.jpg',
      'cover_image_url': 'https://example.com/farm.jpg',
      'rating': 4.8,
      'follower_count': 27,
      'is_following': true,
      'products': [
        {'name': 'Tomatoes', 'is_available': true},
        {'name': 'Squash', 'is_available': false},
      ],
    });

    expect(farmer.name, 'Maria Santos');
    expect(farmer.farmId, 18);
    expect(farmer.location, 'Bukidnon');
    expect(farmer.imageUrl, 'https://example.com/maria.jpg');
    expect(farmer.coverImageUrl, 'https://example.com/farm.jpg');
    expect(farmer.rating, 4.8);
    expect(farmer.followerCount, 27);
    expect(farmer.isFollowing, isTrue);
    expect(farmer.products, hasLength(2));
    expect(farmer.products.first.isAvailable, isTrue);
    expect(farmer.products.last.isAvailable, isFalse);
  });

  test('uses first and last initials when a farmer has no profile image', () {
    final farmer = FarmerDirectoryRepository.farmerFromRow({
      'farm_id': 19,
      'farmer_name': 'Juan Dela Cruz',
      'farm_location': 'Benguet',
      'profile_image_url': ' ',
      'products': <Object>[],
    });

    expect(farmer.imageUrl, isNull);
    expect(farmer.initials, 'JC');
  });

  test('merges follow state without changing directory data', () {
    final farmers = FarmerDirectoryRepository.mergeRows(
      directoryRows: [
        {
          'farm_id': 22,
          'farmer_name': 'Ana Reyes',
          'farm_location': 'Benguet',
          'rating': 4.9,
          'products': <Object>[],
        },
      ],
      followStateRows: [
        {'farm_id': 22, 'follower_count': 31, 'is_following': true},
      ],
    );

    expect(farmers.single.name, 'Ana Reyes');
    expect(farmers.single.rating, 4.9);
    expect(farmers.single.followerCount, 31);
    expect(farmers.single.isFollowing, isTrue);
  });

  test('keeps directory farmers when follow state is unavailable', () {
    final farmers = FarmerDirectoryRepository.mergeRows(
      directoryRows: [
        {
          'farm_id': 23,
          'farmer_name': 'Ben Cruz',
          'farm_location': 'Davao',
          'rating': 4.5,
          'products': <Object>[],
        },
      ],
      followStateRows: const [],
    );

    expect(farmers.single.name, 'Ben Cruz');
    expect(farmers.single.followerCount, 0);
    expect(farmers.single.isFollowing, isFalse);
  });

  test('accepts legacy follow_count response aliases', () {
    final farmer = FarmerDirectoryRepository.farmerFromRow({
      'farm_id': 24,
      'farmer_name': 'Legacy Farm',
      'farm_location': 'Cebu',
      'follow_count': 9,
      'products': <Object>[],
    });

    expect(farmer.followerCount, 9);
  });
}
