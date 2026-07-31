import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/auth/domain/saved_account.dart';

class AccountSessionStore {
  AccountSessionStore([this._secureStorage = const FlutterSecureStorage()]);

  static const _accountsKey = 'auth.saved-accounts.v1';
  static const _credentialPrefix = 'auth.saved-session.v1.';

  final FlutterSecureStorage _secureStorage;

  Future<List<SavedAccount>> loadAccounts() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_accountsKey);
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];
      return [
        for (final value in decoded)
          if (value is Map)
            SavedAccount.fromJson(
              value.map((key, item) => MapEntry('$key', item)),
            ),
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> saveAccount(SavedAccount account) async {
    final accounts = await loadAccounts();
    final updated = <SavedAccount>[
      account,
      ...accounts.where((item) => item.id != account.id),
    ];
    await _writeAccounts(updated);
  }

  Future<void> removeAccount(
    String accountId, {
    bool removeCredential = true,
  }) async {
    final accounts = await loadAccounts();
    await _writeAccounts(
      accounts.where((account) => account.id != accountId).toList(),
    );
    if (removeCredential) await deleteCredential(accountId);
  }

  Future<bool> containsAccount(String accountId) async {
    final accounts = await loadAccounts();
    return accounts.any((account) => account.id == accountId);
  }

  Future<String?> readCredential(String accountId) {
    return _secureStorage.read(key: '$_credentialPrefix$accountId');
  }

  Future<void> writeCredential(String accountId, String credential) {
    return _secureStorage.write(
      key: '$_credentialPrefix$accountId',
      value: credential,
    );
  }

  Future<void> deleteCredential(String accountId) {
    return _secureStorage.delete(key: '$_credentialPrefix$accountId');
  }

  Future<void> _writeAccounts(List<SavedAccount> accounts) async {
    final preferences = await SharedPreferences.getInstance();
    if (accounts.isEmpty) {
      await preferences.remove(_accountsKey);
      return;
    }
    await preferences.setString(
      _accountsKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
  }
}
