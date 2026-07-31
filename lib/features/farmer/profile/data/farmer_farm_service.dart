import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';

class FarmerFarmService {
  const FarmerFarmService();

  Future<FarmModel?> load() async {
    if (!AgrisellSupabase.isInitialized) return null;
    try {
      final owner = await _owner();
      final row = await AgrisellSupabase.client
          .from('farms')
          .select(_farmFields)
          .eq('farmer_user_id', owner.farmerId)
          .limit(1)
          .maybeSingle();
      return row == null ? null : FarmModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw FarmerFarmException(_message(error));
    }
  }

  Future<FarmModel> save(FarmEditDraft draft, {int? farmId}) async {
    if (!AgrisellSupabase.isInitialized) return _localFarm(draft, farmId);
    if (draft.name.trim().isEmpty) {
      throw const FarmerFarmException('Enter a farm name.');
    }
    try {
      final owner = await _owner();
      final values = draft.toDatabase(owner.farmerId);
      final query = AgrisellSupabase.client.from('farms');
      final row = farmId == null
          ? await query.insert(values).select(_farmFields).single()
          : await query
                .update(values)
                .eq('farm_id', farmId)
                .select(_farmFields)
                .single();
      return FarmModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw FarmerFarmException(_message(error));
    }
  }

  Future<_FarmOwner> _owner() async {
    final client = AgrisellSupabase.client;
    final authUserId = client.auth.currentUser?.id;
    if (authUserId == null) {
      throw const FarmerFarmException('Please sign in as a farmer first.');
    }
    final farmer = await client
        .from('farmers')
        .select('farmer_user_id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();
    if (farmer == null) {
      throw const FarmerFarmException('Farmer profile was not found.');
    }
    return _FarmOwner(farmer['farmer_user_id'] as int);
  }

  FarmModel _localFarm(FarmEditDraft draft, int? farmId) => FarmModel(
    id: farmId ?? 0,
    farmerId: 0,
    name: draft.name.trim(),
    location: draft.location,
    barangay: draft.barangay,
    cityMunicipality: draft.cityMunicipality,
    province: draft.province,
    latitude: draft.latitude,
    longitude: draft.longitude,
    size: draft.size,
    farmingType: draft.farmingType,
    irrigationType: draft.irrigationType,
    mainCrops: draft.mainCrops,
  );
}

class FarmEditDraft {
  const FarmEditDraft({
    required this.name,
    required this.location,
    required this.barangay,
    required this.cityMunicipality,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.size,
    required this.farmingType,
    required this.irrigationType,
    required this.mainCrops,
  });

  final String name;
  final String? location;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final double? size;
  final String? farmingType;
  final String? irrigationType;
  final List<String> mainCrops;

  Map<String, Object?> toDatabase(int farmerId) => {
    'farmer_user_id': farmerId,
    'farm_name': name.trim(),
    'farm_location': location,
    'barangay': barangay,
    'city_municipality': cityMunicipality,
    'province': province,
    'gps_lat': latitude,
    'gps_long': longitude,
    'farm_size_hectares': size,
    'farming_type': farmingType,
    'irrigation_type': irrigationType,
    'main_crops': mainCrops,
  };
}

class FarmerFarmException implements Exception {
  const FarmerFarmException(this.message);

  final String message;
}

class _FarmOwner {
  const _FarmOwner(this.farmerId);

  final int farmerId;
}

const _farmFields =
    'farm_id,farmer_user_id,farm_name,farm_location,barangay,'
    'city_municipality,province,gps_lat,gps_long,main_crops,'
    'farm_size_hectares,farming_type,irrigation_type';

String _message(PostgrestException error) => switch (error.code) {
  '42501' => 'You are not authorized to edit this farm.',
  _ when error.message.trim().isNotEmpty => error.message.trim(),
  _ => 'Farm details could not be saved. Please try again.',
};
