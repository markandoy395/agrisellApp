import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

enum FarmerProfileMode { overview, edit, editFarm }

class FarmerProfileController extends ChangeNotifier {
  FarmerProfileController({required this.verificationRepository})
    : profile = currentAuthenticatedUserProfile();

  FarmerVerificationRepository verificationRepository;
  UserProfile profile;
  FarmerProfileMode mode = FarmerProfileMode.overview;
  ProfileFollowCounts followCounts = const ProfileFollowCounts();
  FarmerVerificationDetails? verificationDetails;
  bool _disposed = false;

  Future<void> loadVerificationDetails() async {
    final details = await verificationRepository.loadVerificationDetails();
    if (!_disposed && details != null) {
      verificationDetails = details;
      notifyListeners();
    }
  }

  Future<void> loadFollowCounts() async {
    try {
      final counts = await const ProfileFollowCountsRepository().load();
      if (!_disposed) {
        followCounts = counts;
        notifyListeners();
      }
    } on ProfileFollowCountsException {
      // Keep zero-value placeholders when profile statistics are unavailable.
    }
  }

  void openEditProfile() {
    mode = FarmerProfileMode.edit;
    notifyListeners();
  }

  void openEditFarm() {
    mode = FarmerProfileMode.editFarm;
    notifyListeners();
  }

  void showOverview() {
    mode = FarmerProfileMode.overview;
    notifyListeners();
  }

  Future<bool> saveProfile(UserProfile updatedProfile) async {
    final saved = await UserProfileService.instance.save(updatedProfile);
    if (_disposed) return false;
    profile = saved;
    showOverview();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
