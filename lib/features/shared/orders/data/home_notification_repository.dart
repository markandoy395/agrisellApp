import 'dart:async';
import 'package:agresell_app/core/services/query_owner.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_cache.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_mapper.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

part 'home_notification_repository_sync.dart';

class HomeNotificationRepository {
  const HomeNotificationRepository({
    this.cache = const SharedPreferencesHomeNotificationCache(),
    SupabaseClient? client,
  }) : _providedClient = client;

  static const pageSize = 30;
  static const _columns =
      'notification_id,recipient_auth_user_id,title,description,'
      'created_at,read_at,notification_type,category,destination,'
      'order_id,metadata';
  static const _mapper = HomeNotificationMapper();

  final HomeNotificationCache cache;
  final SupabaseClient? _providedClient;

  SupabaseClient? get _client {
    if (_providedClient != null) return _providedClient;
    return AgrisellSupabase.isInitialized ? AgrisellSupabase.client : null;
  }

  Future<List<HomeNotification>> loadCachedForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Future.value(const []);
    }
    if (_client != null) QueryOwner(_client!).requireAuthId(userId);
    return cache.read(userId);
  }

  HomeNotification? firstUnreadFarmerApproval(
    Iterable<HomeNotification> notifications,
  ) {
    for (final notification in notifications) {
      if (!notification.isRead &&
          notification.title == 'Farmer account approved') {
        return notification;
      }
    }
    return null;
  }

  Future<List<HomeNotification>> loadForUser(
    String? userId, {
    int limit = pageSize,
    int offset = 0,
  }) async {
    if (userId == null || userId.isEmpty) return const [];
    final client = _client;
    if (client == null) return cache.read(userId);
    QueryOwner(client).requireAuthId(userId);
    await _flushPending(client, userId);
    final rows = await client
        .from('notifications')
        .select(_columns)
        .eq('recipient_auth_user_id', userId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final notifications = (rows as List)
        .whereType<Map<String, Object?>>()
        .map(_mapper.fromRow)
        .toList(growable: false);
    if (offset == 0) await cache.write(userId, notifications);
    return notifications;
  }

  Stream<List<HomeNotification>> watchForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream.value(const []);
    }
    if (_client != null) QueryOwner(_client!).requireAuthId(userId);
    late final StreamController<List<HomeNotification>> controller;
    RealtimeChannel? channel;
    var hasData = false;
    var refreshing = false;
    var refreshAgain = false;

    Future<void> refresh() async {
      if (refreshing) {
        refreshAgain = true;
        return;
      }
      refreshing = true;
      do {
        refreshAgain = false;
        try {
          final values = await loadForUser(userId);
          if (!controller.isClosed) controller.add(values);
          hasData = true;
        } catch (error, stackTrace) {
          if (!hasData && !controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        }
      } while (refreshAgain && !controller.isClosed);
      refreshing = false;
    }

    Future<void> listen() async {
      final cached = await cache.read(userId);
      if (cached.isNotEmpty && !controller.isClosed) {
        hasData = true;
        controller.add(cached);
      }
      final client = _client;
      if (client == null || controller.isClosed) {
        if (!hasData && !controller.isClosed) controller.add(const []);
        return;
      }
      channel = client
          .channel(
            'notifications:$userId:'
            '${DateTime.now().microsecondsSinceEpoch}',
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'recipient_auth_user_id',
              value: userId,
            ),
            callback: (_) => unawaited(refresh()),
          )
          .subscribe();
      await refresh();
    }

    controller = StreamController<List<HomeNotification>>(
      onListen: () => unawaited(listen()),
      onCancel: () async {
        final activeChannel = channel;
        final client = _client;
        if (activeChannel != null && client != null) {
          await client.removeChannel(activeChannel);
        }
      },
    );
    return controller.stream;
  }
}
