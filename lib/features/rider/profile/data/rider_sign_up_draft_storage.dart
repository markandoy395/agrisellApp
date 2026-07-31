import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';

abstract interface class RiderSignUpDraftStorage {
  Future<RiderSignUpDraft?> load();
  Future<void> save(RiderSignUpDraft draft);
  Future<void> clear();
}

class SharedPreferencesRiderSignUpDraftStorage
    implements RiderSignUpDraftStorage {
  SharedPreferencesRiderSignUpDraftStorage({this._preferences});

  static const _draftKey = 'rider_sign_up_draft_v1';
  SharedPreferencesAsync? _preferences;

  @override
  Future<RiderSignUpDraft?> load() async {
    final preferences = _instance;
    if (preferences == null) return null;
    final raw = await preferences.getString(_draftKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return RiderSignUpDraft.fromJson(_map(decoded));
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(RiderSignUpDraft draft) async {
    final preferences = _instance;
    if (preferences != null) {
      await preferences.setString(_draftKey, jsonEncode(draft.toJson()));
    }
  }

  @override
  Future<void> clear() async {
    final preferences = _instance;
    if (preferences != null) await preferences.remove(_draftKey);
  }

  SharedPreferencesAsync? get _instance {
    try {
      return _preferences ??= SharedPreferencesAsync();
    } on StateError {
      return null;
    }
  }
}

Map<String, Object?> _map(Map raw) => {
  for (final entry in raw.entries)
    if (entry.key is String) entry.key as String: entry.value,
};
