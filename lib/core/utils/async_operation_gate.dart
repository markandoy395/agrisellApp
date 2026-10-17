import 'dart:async';

/// Shares an in-flight request and serializes mutations of the same resource.
class AsyncOperationGate {
  final Map<Object, Future<Object?>> _active = {};
  final Map<Object, Future<void>> _tails = {};

  Future<T> run<T>(Object key, Future<T> Function() action) {
    final existing = _active[key];
    if (existing != null) return existing as Future<T>;
    final completer = Completer<T>();
    _active[key] = completer.future;
    () async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        if (identical(_active[key], completer.future)) _active.remove(key);
      }
    }();
    return completer.future;
  }

  Future<T> serialize<T>(Object resource, Future<T> Function() action) {
    final previous = _tails[resource];
    final completer = Completer<T>();
    final done = Completer<void>();
    _tails[resource] = done.future;
    () async {
      try {
        if (previous != null) await previous;
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        done.complete();
        if (identical(_tails[resource], done.future)) _tails.remove(resource);
      }
    }();
    return completer.future;
  }
}
