import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';

/// One bounded first-page snapshot, available only to its authenticated owner.
class HomeProductSnapshotCache {
  HomeProductSnapshotCache({
    String? Function()? owner,
    DateTime Function()? now,
  }) : _owner = owner ?? authenticatedOwner,
       _now = now ?? DateTime.now;

  static final instance = HomeProductSnapshotCache();
  static const storageKey = 'home.catalog.snapshot.v1';
  static const maxAge = Duration(minutes: 15);
  final String? Function() _owner;
  final DateTime Function() _now;
  Future<void> _writes = Future<void>.value();
  var _generation = 0;
  int get generation => _generation;

  static String? authenticatedOwner() {
    if (!AgrisellSupabase.isInitialized) return null;
    final session = AgrisellSupabase.client.auth.currentSession;
    if (session == null || session.isExpired || session.user.isAnonymous) {
      return null;
    }
    return session.user.id;
  }

  Future<List<Map<String, dynamic>>?> read(int limit) async {
    final owner = _owner();
    final generation = _generation;
    if (owner == null) return null;
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(storageKey);
      if (encoded == null || generation != _generation || owner != _owner()) {
        return null;
      }
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final age = _now().difference(DateTime.parse(data['savedAt'] as String));
      if (data['owner'] != owner ||
          data['limit'] != limit ||
          age.isNegative ||
          age > maxAge)
        return null;
      return (data['rows'] as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
    } on Object {
      return null;
    }
  }

  Future<void> save(
    String? owner,
    int limit,
    List<Map<String, dynamic>> rows, {
    int? generation,
  }) {
    final expectedGeneration = generation ?? _generation;
    return _enqueue(() async {
      if (owner == null ||
          owner != _owner() ||
          expectedGeneration != _generation)
        return;
      final preferences = await SharedPreferences.getInstance();
      if (owner != _owner() || expectedGeneration != _generation) return;
      await preferences.setString(
        storageKey,
        jsonEncode({
          'owner': owner,
          'limit': limit,
          'savedAt': _now().toUtc().toIso8601String(),
          'rows': rows.take(limit).toList(growable: false),
        }),
      );
    });
  }

  Future<void> clear() {
    _generation++;
    return _enqueue(() async {
      await (await SharedPreferences.getInstance()).remove(storageKey);
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    return _writes = _writes.then((_) async {
      try {
        await action();
      } on Object {
        // Cache failures never fail catalogue loading or logout.
      }
    });
  }
}
