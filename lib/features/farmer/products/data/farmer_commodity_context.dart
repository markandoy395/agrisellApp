import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';

class FarmerCommodityContext {
  const FarmerCommodityContext(this.authUserId, this.farmId, this.isVerified);

  final String authUserId;
  final int farmId;
  final bool isVerified;

  static Future<FarmerCommodityContext> load() async {
    final client = AgrisellSupabase.client;
    final authUserId = client.auth.currentUser?.id;
    if (authUserId == null) {
      throw const FarmerCommodityException('Please sign in as a farmer first.');
    }
    final farmer = await client
        .from('farmers')
        .select('farmer_user_id, verification_status')
        .eq('auth_user_id', authUserId)
        .maybeSingle();
    if (farmer == null) {
      throw const FarmerCommodityException('Farmer profile was not found.');
    }
    final farm = await client
        .from('farms')
        .select('farm_id')
        .eq('farmer_user_id', farmer['farmer_user_id'])
        .limit(1)
        .maybeSingle();
    if (farm == null) throw const FarmRequiredException();

    return FarmerCommodityContext(
      authUserId,
      FarmerCommodityFormat.integer(farm['farm_id']),
      FarmerCommodityFormat.text(farmer['verification_status']).toLowerCase() ==
          'verified',
    );
  }

  static Future<void> createFarm(String name) async {
    final farmName = name.trim();
    if (farmName.isEmpty) {
      throw const FarmerCommodityException('Enter a farm name.');
    }
    final client = AgrisellSupabase.client;
    final authUserId = client.auth.currentUser?.id;
    if (authUserId == null) {
      throw const FarmerCommodityException('Please sign in as a farmer first.');
    }
    final farmer = await client
        .from('farmers')
        .select('farmer_user_id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();
    if (farmer == null) {
      throw const FarmerCommodityException('Farmer profile was not found.');
    }
    await client.from('farms').insert({
      'farmer_user_id': farmer['farmer_user_id'],
      'farm_name': farmName,
    });
  }

  Future<Map<int, String>> loadCategories() async {
    final rows = await AgrisellSupabase.client
        .from('categories')
        .select('category_id, category_name')
        .eq('farm_id', farmId);
    return {
      for (final row in (rows as List).whereType<Map<String, dynamic>>())
        FarmerCommodityFormat.integer(row['category_id']):
            FarmerCommodityFormat.text(row['category_name']),
    };
  }

  Future<int> resolveCategory(String name) async {
    final client = AgrisellSupabase.client;
    final existing = await client
        .from('categories')
        .select('category_id')
        .eq('farm_id', farmId)
        .eq('category_name', name)
        .maybeSingle();
    if (existing != null) {
      return FarmerCommodityFormat.integer(existing['category_id']);
    }
    final category = await client
        .from('categories')
        .insert({'farm_id': farmId, 'category_name': name})
        .select('category_id')
        .single();
    return FarmerCommodityFormat.integer(category['category_id']);
  }
}
