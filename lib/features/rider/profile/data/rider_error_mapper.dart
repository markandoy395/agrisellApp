import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/profile/data/rider_repository_exception.dart';

Future<T> guardRiderOperation<T>(Future<T> Function() action) async {
  try {
    return await action().timeout(const Duration(seconds: 30));
  } on RiderRepositoryException {
    rethrow;
  } on TimeoutException {
    throw const RiderRepositoryException(
      'The request timed out. Check your connection and retry.',
      type: RiderFailureType.timeout,
    );
  } on SocketException {
    throw const RiderRepositoryException(
      'No network connection. Reconnect and retry.',
      type: RiderFailureType.network,
    );
  } on AuthException {
    throw const RiderRepositoryException(
      'Your session is unavailable. Please log in again.',
      type: RiderFailureType.authentication,
      isRecoverable: false,
    );
  } on StorageException catch (error) {
    throw RiderRepositoryException(
      _safeStorageMessage(error),
      type: RiderFailureType.storage,
    );
  } on PostgrestException catch (error) {
    final isConflict = error.code == '23505';
    throw RiderRepositoryException(
      isConflict
          ? 'That Rider information is already registered.'
          : 'The Rider information could not be saved. Please retry.',
      type: isConflict ? RiderFailureType.conflict : RiderFailureType.database,
      isRecoverable: !isConflict,
    );
  } on Exception {
    throw const RiderRepositoryException(
      'The Rider request could not be completed. Please retry.',
    );
  }
}

String _safeStorageMessage(StorageException error) {
  if (error.statusCode == '413') return 'The selected file is too large.';
  if (error.statusCode == '401' || error.statusCode == '403') {
    return 'You do not have access to that Rider file.';
  }
  return 'The Rider document could not be uploaded. Please retry.';
}
