import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/data/supabase_marketplace_messaging_repository.dart';

MarketplaceMessagingRepository currentMarketplaceMessagingRepository() {
  if (!AgrisellSupabase.isInitialized ||
      AgrisellSupabase.client.auth.currentUser == null) {
    return const EmptyMarketplaceMessagingRepository();
  }
  return SupabaseMarketplaceMessagingRepository(AgrisellSupabase.client);
}
