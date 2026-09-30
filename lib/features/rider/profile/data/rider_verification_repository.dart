import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

abstract interface class RiderVerificationRepository {
  Future<RiderVerificationDetails> getVerificationDetails({String? reference});
}
