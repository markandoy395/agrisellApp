import 'package:supabase_flutter/supabase_flutter.dart';

String supportErrorMessage(Object error, {required String fallback}) {
  if (error is PostgrestException &&
      (error.code == 'PGRST202' ||
          error.code == 'PGRST205' ||
          error.code == '42P01')) {
    return 'Customer support is temporarily unavailable. Please try again later.';
  }
  return fallback;
}
