import 'dart:convert';

import 'package:agresell_app/features/auth/data/auth_login_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_login_failure_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/supabase_account_loader.dart';
import 'package:agresell_app/features/auth/data/supabase_auth_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'login and recovery send the exact same password to the same server',
    () async {
      final requests = <http.Request>[];
      final client = _client((request) async {
        requests.add(request);
        return _response(
          request,
          request.url.path.endsWith('/token')
              ? _session()
              : {
                  'error_code': 'same_password',
                  'msg':
                      'New password should be different from the old password.',
                },
          status: request.url.path.endsWith('/token') ? 200 : 422,
        );
      });
      addTearDown(client.dispose);
      final loader = _Loader(client);
      final service = SupabaseAuthService.forTesting(
        client: client,
        accountLoader: loader,
      );
      // Whitespace, punctuation and case must remain literal password data.
      const password = ' P@ssword123!_%\' ';
      final account = await service.authenticate(
        ' BUYER@EXAMPLE.INVALID ',
        password,
      );
      expect(account, same(_account));
      expect(loader.loads, 1);
      await expectLater(
        service.updatePasswordAfterRecovery(password),
        throwsA(
          isA<AuthException>().having(
            (error) => error.code,
            'code',
            'same_password',
          ),
        ),
      );
      expect(requests, hasLength(2));
      expect(requests[0].url.host, requests[1].url.host);
      expect(requests[0].url.queryParameters['grant_type'], 'password');
      expect(jsonDecode(requests[0].body)['email'], 'buyer@example.invalid');
      for (final request in requests) {
        expect(jsonDecode(request.body)['password'], password);
      }
    },
  );

  test('invalid credentials stop login before any profile lookup', () async {
    final client = _client(
      (request) async => _response(request, {
        'error_code': 'invalid_credentials',
        'msg': 'Invalid login credentials',
      }, status: 400),
    );
    addTearDown(client.dispose);
    final loader = _Loader(client);
    final service = SupabaseAuthService.forTesting(
      client: client,
      accountLoader: loader,
    );
    await expectLater(
      service.authenticate('buyer@example.invalid', 'wrong'),
      throwsA(
        isA<AuthException>().having(
          AuthLoginErrorMapper.isInvalidCredentials,
          'credential mismatch',
          true,
        ),
      ),
    );
    expect(loader.loads, 0);
  });

  test(
    'valid password with profile failure is not a credential mismatch',
    () async {
      final client = _client((request) async => _response(request, _session()));
      addTearDown(client.dispose);
      final loader = _Loader(client)
        ..failure = const PostgrestException(
          message: 'private database detail',
          code: '42501',
        );
      final service = SupabaseAuthService.forTesting(
        client: client,
        accountLoader: loader,
      );
      try {
        await service.authenticate('buyer@example.invalid', 'Correct123!');
        fail('Profile failure must propagate.');
      } on PostgrestException catch (error) {
        final message = AuthLoginFailureMapper.map(error).message;
        expect(message, contains('account profile'));
        expect(message, isNot(contains('incorrect')));
        expect(message, isNot(contains('private database detail')));
      }
      expect(loader.loads, 1);
    },
  );

  test('missing profile after valid credentials has its own error', () async {
    final client = _client((request) async => _response(request, _session()));
    addTearDown(client.dispose);
    final loader = _Loader(client)..account = null;
    final service = SupabaseAuthService.forTesting(
      client: client,
      accountLoader: loader,
    );
    await expectLater(
      service.authenticate('buyer@example.invalid', 'Correct123!'),
      throwsA(
        isA<AuthRegistrationException>().having(
          (error) => error.message,
          'message',
          contains('profile could not be loaded'),
        ),
      ),
    );
  });
}

SupabaseClient _client(Future<http.Response> Function(http.Request) handler) =>
    SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient(handler),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

http.Response _response(
  http.Request request,
  Object body, {
  int status = 200,
}) => http.Response(
  jsonEncode(body),
  status,
  request: request,
  headers: {'content-type': 'application/json'},
);

Map<String, Object?> _session() => {
  'access_token': 'test-token',
  'refresh_token': 'test-refresh',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': {
    'id': _account.id,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': _account.email,
    'created_at': '2026-01-01T00:00:00Z',
    'email_confirmed_at': '2026-01-01T00:00:00Z',
    'app_metadata': <String, Object?>{},
    'user_metadata': <String, Object?>{},
    'is_anonymous': false,
  },
};

const _account = RegisteredAccount(
  id: 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
  firstName: 'Ana',
  lastName: 'Reyes',
  email: 'buyer@example.invalid',
  passwordHash: '',
  passwordSalt: '',
  role: 'buyer',
  accountStatus: 'active',
);

class _Loader extends SupabaseAccountLoader {
  _Loader(super.client);
  var loads = 0;
  Object? failure;
  RegisteredAccount? account = _account;
  @override
  Future<RegisteredAccount?> load() async {
    loads++;
    if (failure case final error?) throw error;
    return account;
  }
}
