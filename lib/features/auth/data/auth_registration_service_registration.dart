part of 'auth_registration_service.dart';

extension AuthRegistrationServiceRegistration on AuthRegistrationService {
  Future<RegisteredAccount> register(SignUpAccountData data, AuthRole role) =>
      _register(data, role);

  Future<RegisteredAccount> registerFarmer(FarmerSignupData data) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.register(
        SignUpAccountData(
          firstName: data.firstName,
          lastName: data.lastName,
          email: data.email,
          password: data.password,
          extensionName: data.suffix,
          middleName: data.middleName,
          phoneNumber: data.phoneNumber,
          dateOfBirth: data.dateOfBirth,
          gender: data.gender,
        ),
        AuthRole.farmer,
      );
    }
    try {
      _remoteAccount = await const FarmerRegistrationService().register(data);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    } catch (_) {
      throw const AuthRegistrationException(
        'Farmer registration could not be completed. Please try again.',
      );
    }
  }

  Future<RegisteredAccount> completeVerifiedBuyerRegistration(
    SignUpAccountData data,
  ) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.register(data, AuthRole.buyer);
    }
    try {
      _remoteAccount = await _remote.completeVerifiedBuyerRegistration(data);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'Buyer registration could not be completed after verification.',
      );
    }
  }

  Future<RegisteredAccount> completeVerifiedFarmerRegistration(
    FarmerSignupData data,
  ) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Email verification is temporarily unavailable. Please try again later.',
      );
    }
    try {
      _remoteAccount = await const FarmerRegistrationService()
          .completeVerifiedRegistration(data);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'Farmer registration could not be completed after verification.',
      );
    }
  }

  Future<RegisteredAccount> registerRider(
    SignUpAccountData data,
    Map<String, Object?> application,
  ) => _register(data, AuthRole.rider, riderApplication: application);

  Future<RegisteredAccount> _register(
    SignUpAccountData data,
    AuthRole role, {
    Map<String, Object?>? riderApplication,
  }) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.register(
        data,
        role,
        isRiderApplication: riderApplication != null,
      );
    }
    try {
      _remoteAccount = await _remote.register(
        data,
        role,
        riderApplication: riderApplication,
      );
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    } catch (_) {
      throw const AuthRegistrationException(
        "We couldn't create your account right now. Please try again.",
      );
    }
  }

  Future<RegisteredAccount> saveBuyerShippingAddress(
    RegisteredAccount account,
    BuyerShippingAddress address,
  ) async {
    if (account.assignedRole != AuthRole.buyer) {
      throw const AuthRegistrationException(
        'Only buyers can set shipping addresses.',
      );
    }
    if (!usesSupabase) {
      final saved = _local.updateShippingAddress(
        account.id,
        address.address,
        latitude: address.latitude,
        longitude: address.longitude,
      );
      if (saved != null) return saved;
      throw const AuthRegistrationException('Your account could not be found.');
    }
    try {
      final savedAddress = await _remote.saveBuyerShippingAddress(address);
      final saved = account.copyWith(
        shippingAddress: savedAddress.address,
        shippingLatitude: savedAddress.latitude,
        shippingLongitude: savedAddress.longitude,
      );
      _remoteAccount = saved;
      return saved;
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'Your shipping address could not be saved. Please retry.',
      );
    }
  }
}
