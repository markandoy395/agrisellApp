enum RiderCommunicationLoadState { loading, ready, error, offline }

class RiderCommunicationException implements Exception {
  const RiderCommunicationException(this.message, {this.isOffline = false});

  final String message;
  final bool isOffline;

  @override
  String toString() => message;
}
