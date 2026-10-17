import 'package:agresell_app/core/services/agrisell_supabase.dart';

/// Rejects late results after disposal, replacement, logout or account change.
class AsyncRequestScope {
  final Map<Object, int> _versions = {};
  bool _disposed = false;

  AsyncRequestTicket begin(Object key) {
    final version = (_versions[key] ?? 0) + 1;
    _versions[key] = version;
    return AsyncRequestTicket(this, key, version, _owner);
  }

  void invalidate(Object key) => _versions[key] = (_versions[key] ?? 0) + 1;
  void dispose() {
    _disposed = true;
    _versions.clear();
  }

  static String? get _owner {
    if (!AgrisellSupabase.isInitialized) return null;
    final session = AgrisellSupabase.client.auth.currentSession;
    if (session == null || session.user.isAnonymous || session.isExpired) {
      return '';
    }
    return session.user.id;
  }
}

class AsyncRequestTicket {
  const AsyncRequestTicket(this._scope, this._key, this._version, this._owner);
  final AsyncRequestScope _scope;
  final Object _key;
  final int _version;
  final String? _owner;

  bool get isActive => !_scope._disposed && _owner == AsyncRequestScope._owner;

  bool get isCurrent => isActive && _scope._versions[_key] == _version;
}
