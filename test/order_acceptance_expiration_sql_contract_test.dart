import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String foundation;
  late String processing;
  late String paymentReview;
  late String refunds;
  late String snapshots;
  late String resubmission;
  late String reminders;

  setUpAll(() {
    foundation = _migration(
      '20260730100000_order_acceptance_expiration_foundation.sql',
    );
    processing = _migration(
      '20260730100001_process_order_acceptance_expirations.sql',
    );
    paymentReview = _migration(
      '20260730100002_resolve_expired_gcash_payments.sql',
    );
    refunds = _migration('20260730100003_allow_expired_order_refunds.sql');
    snapshots = _migration(
      '20260730100004_expose_order_acceptance_expiration.sql',
    );
    resubmission = _migration(
      '20260730100005_harden_expired_gcash_resubmission.sql',
    );
    reminders = _migration(
      '20260730100006_schedule_order_acceptance_reminders.sql',
    );
  });

  test('checkout receives a four-business-hour Manila deadline', () {
    expect(foundation, contains('acceptance_expires_at'));
    expect(foundation, contains("'Asia/Manila'"));
    expect(foundation, contains("time '06:00'"));
    expect(foundation, contains("time '20:00'"));
    expect(foundation, contains("interval '4 hours'"));
    expect(foundation, contains('orders_set_acceptance_deadline'));
  });

  test('late farmer acceptance is rejected atomically', () {
    expect(foundation, contains('orders_guard_expired_acceptance'));
    expect(foundation, contains("old.order_status <> 'toShip'"));
    expect(foundation, contains("new.order_status = 'preparing'"));
    expect(foundation, contains('acceptance_expires_at <= now()'));
    expect(foundation, contains('acceptance_expired_at is not null'));
  });

  test('scheduled expiration releases reserved stock once', () {
    expect(processing, contains('pg_advisory_xact_lock'));
    expect(processing, contains('stock_released_at is null'));
    expect(
      processing,
      contains('available_quantity = available_quantity + released.quantity'),
    );
    expect(processing, contains("set order_status = 'expired'"));
    expect(processing, contains("'*/5 * * * *'"));
    expect(processing, contains('cron.schedule'));
  });

  test('payment outcomes remain safe when an order expires', () {
    expect(processing, contains("then 'refund_required'"));
    expect(processing, contains("then 'payment_review_required'"));
    expect(processing, contains("else 'cancelled'"));
    expect(processing, contains("'order_expired'"));
    expect(processing, contains('private.order_acceptance_events'));
  });

  test('farmer receives halfway and final deadline reminders', () {
    expect(foundation, contains('acceptance_halfway_at'));
    expect(foundation, contains("interval '2 hours'"));
    expect(reminders, contains("'halfway_reminder'"));
    expect(reminders, contains("'deadline_reminder'"));
    expect(reminders, contains("interval '30 minutes'"));
    expect(reminders, contains("'order_expiring'"));
    expect(reminders, contains('cron.schedule'));
  });

  test('expired GCash review cannot restore fulfillment', () {
    expect(paymentReview, contains('process_order_acceptance_deadlines'));
    expect(
      paymentReview,
      contains("current_payment_status = 'payment_review_required'"),
    );
    expect(
      paymentReview,
      contains("when expired_order and approved then 'refund_required'"),
    );
    expect(paymentReview, contains("'expired_payment_reviewed'"));
  });

  test('refunds and expiration metadata are account scoped', () {
    expect(refunds, contains("order_status in ('cancelled', 'expired')"));
    expect(refunds, contains("payment_status = 'refunded'"));
    expect(snapshots, contains('private.owns_order(order_record.order_id)'));
    expect(snapshots, contains('current_account_expiration_snapshots'));
    expect(snapshots, contains('acceptanceExpiredAt'));
  });

  test('expired orders cannot race a GCash resubmission or refund', () {
    expect(resubmission, contains('process_order_acceptance_deadlines'));
    expect(resubmission, contains('pg_advisory_xact_lock'));
    expect(resubmission, contains("order_status = 'toShip'"));
    expect(resubmission, contains('acceptance_expires_at > now()'));
    expect(refunds, contains("'refund:' || target_client_order_id"));
    expect(refunds, contains('for update'));
  });
}

String _migration(String name) =>
    File('supabase/migrations/$name').readAsStringSync();
