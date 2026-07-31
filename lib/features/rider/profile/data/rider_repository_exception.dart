enum RiderFailureType {
  authentication,
  validation,
  conflict,
  network,
  timeout,
  storage,
  database,
  unknown,
}

class RiderRepositoryException implements Exception {
  const RiderRepositoryException(
    this.message, {
    this.type = RiderFailureType.unknown,
    this.isRecoverable = true,
  });

  final String message;
  final RiderFailureType type;
  final bool isRecoverable;

  @override
  String toString() => message;
}
