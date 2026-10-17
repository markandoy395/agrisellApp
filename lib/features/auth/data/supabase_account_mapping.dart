part of 'supabase_account_loader.dart';

extension _SupabaseAccountMapping on SupabaseAccountLoader {
  Future<String> _roleFor() async =>
      (await _client.rpc<Object?>(
        'current_application_role',
      ))?.toString().trim() ??
      '';

  String _requestedRole(User authUser) {
    final requested = authUser.userMetadata?['requested_role']
        ?.toString()
        .trim()
        .toLowerCase();
    return AuthRole.fromValue(requested ?? '')?.value ?? '';
  }

  String _text(Object? value, {String fallback = ''}) =>
      _nullableText(value) ?? fallback;

  String? _nullableText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  RegisteredAccount _pendingAccount(User authUser, String role) =>
      RegisteredAccount(
        id: authUser.id,
        firstName: '',
        lastName: '',
        email: (authUser.email ?? '').trim().toLowerCase(),
        passwordHash: '',
        passwordSalt: '',
        role: role,
        accountStatus: 'pending',
        verificationStatus: 'pending',
        profilePending: true,
      );

  RegisteredAccount _riderAccount(User authUser, String role, Map rider) {
    final employmentStatus = _nullableText(rider['employment_status']);
    return RegisteredAccount(
      id: authUser.id,
      firstName: _text(rider['first_name']),
      lastName: _text(rider['last_name']),
      email: _text(rider['email']).toLowerCase(),
      passwordHash: '',
      passwordSalt: '',
      role: role,
      accountStatus: employmentStatus == 'suspended'
          ? 'suspended'
          : employmentStatus == 'active'
          ? 'active'
          : 'pending',
      phoneNumber: _nullableText(rider['contact_number']),
      verificationStatus: employmentStatus == 'active'
          ? 'verified'
          : employmentStatus == 'suspended'
          ? 'suspended'
          : 'pending',
      profileImageUrl: _nullableText(rider['profile_photo_url']),
    );
  }

  Future<RegisteredAccount> _withRiderProfileImage(
    RegisteredAccount account,
  ) async {
    final path = account.profileImageUrl;
    if (path == null || Uri.tryParse(path)?.hasScheme == true) return account;
    try {
      final signedUrl = authenticatedStorageUrl(
        _client.storage.from('rider-documents').getPublicUrl(path),
      );
      return account.copyWith(profileImageUrl: signedUrl);
    } on Object {
      return account.copyWith(profileImageUrl: null);
    }
  }
}
