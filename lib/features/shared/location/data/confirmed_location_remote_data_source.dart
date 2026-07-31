import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

abstract interface class ConfirmedLocationRemoteDataSource {
  Future<void> save(LocationOwnerRole role, ConfirmedLocation location);
}
