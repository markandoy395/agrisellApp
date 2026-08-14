import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;
  late String farmerFeedbackSql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260810130000_fix_marketplace_feedback.sql',
    ).readAsStringSync();
    farmerFeedbackSql = File(
      'supabase/migrations/20260810140001_show_farmer_order_feedback.sql',
    ).readAsStringSync();
  });

  test('product reviews retain every marketplace relationship', () {
    expect(sql, contains('buyer_user_id bigint references public.buyers'));
    expect(sql, contains('commodity_id bigint references public.commodities'));
    expect(sql, contains('farmer_user_id bigint references public.farmers'));
    expect(sql, contains('order_item_id bigint references public.order_items'));
    expect(sql, contains('reviews_order_item_id_key'));
  });

  test('submission verifies buyer, purchase, and completed delivery', () {
    expect(sql, contains('submit_current_buyer_feedback'));
    expect(sql, contains('cart.buyer_user_id = actor_buyer_id'));
    expect(sql, contains('cart_item.commodity_id = p_commodity_id'));
    expect(sql, contains("order_status) in ('delivered', 'completed')"));
    expect(
      sql,
      contains("delivery.delivery_status in ('completed', 'delivered')"),
    );
    expect(sql, contains('Only the buyer who placed the order'));
  });

  test('product and rider duplicates are rejected', () {
    expect(sql, contains('existing.order_item_id = purchased_order_item_id'));
    expect(sql, contains('This purchased item has already been reviewed'));
    expect(sql, contains('You have already rated this delivery'));
    expect(sql, contains("reviewer_role, rating, comment"));
    expect(sql, contains("target_rider_id, (select auth.uid()), 'buyer'"));
  });

  test('buyer snapshots return per-product and rider review state', () {
    expect(sql, contains("'itemReviews', snapshot.item_reviews"));
    expect(sql, contains("'deliveryId', snapshot.delivery_id"));
    expect(sql, contains("'riderRated', exists"));
  });

  test('review snapshots include orders owned by the current farmer', () {
    expect(
      farmerFeedbackSql,
      contains('private.current_farmer_user_id() as farmer_user_id'),
    );
    expect(
      farmerFeedbackSql,
      contains('farm.farmer_user_id = actor.farmer_user_id'),
    );
    expect(
      farmerFeedbackSql,
      contains('cart.buyer_user_id = actor.buyer_user_id'),
    );
    expect(farmerFeedbackSql, contains("'itemReviews', snapshot.item_reviews"));
  });
}
