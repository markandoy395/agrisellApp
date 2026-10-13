import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_registration_exception.dart';

class AuthLoginFailureMapper {
  const AuthLoginFailureMapper._();

  static AuthRegistrationException map(Object error) {
    if (error is PostgrestException) {
      diagnose('profile', error.code);
      if (error.code == '429') {
        return const AuthRegistrationException(
          'Too many requests. Please wait before signing in again.',
        );
      }
      return const AuthRegistrationException(
        'Your sign-in reached the server, but your account profile could not '
        'be loaded. Please try again or contact support.',
      );
    }
    if (error is TimeoutException || error is http.ClientException) {
      diagnose('connection', error.runtimeType.toString());
      return const AuthRegistrationException(
        'The app could not reach the sign-in server. Please try again. '
        'If this continues, try another network or contact support.',
      );
    }
    diagnose('unexpected', error.runtimeType.toString());
    return const AuthRegistrationException(
      'Sign-in could not be completed. Please try again or contact support.',
    );
  }

  /// Log only an allowlisted stage and short code, never credentials or payloads.
  static void diagnose(String stage, String? code) {
    if (!kDebugMode) return;
    const stages = {
      'profile',
      'connection',
      'unexpected',
      'authentication',
      'configuration',
    };
    final safeStage = stages.contains(stage) ? stage : 'unexpected';
    final safeCode =
        code != null && RegExp(r'^[a-zA-Z0-9_]{1,64}$').hasMatch(code)
        ? code
        : 'unknown';
    debugPrint('[auth] $safeStage failed ($safeCode)');
  }
}
