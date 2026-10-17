import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';

/// Persists only retry identity and a hash, never the request's private payload.
class PendingOperationStore {
  static final _gate = AsyncOperationGate();
  static const _prefix = 'operations.pending.v1.';

  Future<PendingOperation> prepare(
    String owner,
    String operation,
    Object? payload, {
    bool singlePending = false,
  }) {
    final fingerprint = sha256
        .convert(utf8.encode(jsonEncode(_canonical(payload))))
        .toString();
    final slot =
        '$_prefix$owner.$operation${singlePending ? '' : '.$fingerprint'}';
    return _gate.serialize(slot, () async {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(slot);
      if (encoded != null) {
        final saved = jsonDecode(encoded) as Map<String, dynamic>;
        if (saved['fingerprint'] != fingerprint) {
          throw StateError(
            'An earlier request is unconfirmed. Retry it before changing the request.',
          );
        }
        return PendingOperation(
          slot,
          saved['id'] as String,
          DateTime.parse(saved['createdAt'] as String),
          true,
        );
      }
      final id = newOperationId();
      final createdAt = DateTime.now().toUtc();
      final saved = await prefs.setString(
        slot,
        jsonEncode({
          'id': id,
          'fingerprint': fingerprint,
          'createdAt': createdAt.toIso8601String(),
        }),
      );
      if (!saved) throw StateError('Could not protect this request for retry.');
      return PendingOperation(slot, id, createdAt, false);
    });
  }

  Future<void> complete(
    PendingOperation operation,
  ) => _gate.serialize(operation.slot, () async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(operation.slot);
    if (encoded != null && (jsonDecode(encoded) as Map)['id'] == operation.id) {
      if (!await prefs.remove(operation.slot)) {
        throw StateError('Could not finish saving the request confirmation.');
      }
    }
  });

  static Object? _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => '$key').toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is Iterable) return value.map(_canonical).toList();
    return value;
  }
}

class PendingOperation {
  const PendingOperation(this.slot, this.id, this.createdAt, this.isRetry);
  final String slot;
  final String id;
  final DateTime createdAt;
  final bool isRetry;
}

String newOperationId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
