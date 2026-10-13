import 'package:http/http.dart' as http;

/// Routes REST calls through the server's persistent per-account rate limiter.
/// Auth uses Supabase's own server-side limits; other origins are untouched.
class RateLimitedSupabaseHttpClient extends http.BaseClient {
  RateLimitedSupabaseHttpClient({
    required String projectUrl,
    http.Client? inner,
  }) : _project = Uri.parse(projectUrl),
       _inner = inner ?? http.Client();

  final Uri _project;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url;
    if (url.origin != _project.origin || !url.path.startsWith('/rest/v1/')) {
      return _inner.send(request);
    }
    final target = url.replace(
      path: '/functions/v1/application-api/rest/${url.path.substring(9)}',
    );
    final forwarded = http.Request(request.method, target)
      ..followRedirects = false
      ..headers.addAll(request.headers)
      ..bodyBytes = await request.finalize().toBytes();
    return _inner.send(forwarded);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
