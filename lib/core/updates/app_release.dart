class AppRelease {
  const AppRelease({
    required this.version,
    required this.buildNumber,
    required this.apkUri,
    required this.notes,
  });

  final String version;
  final int buildNumber;
  final Uri apkUri;
  final String notes;

  static AppRelease? parse(Object? value, Uri manifestUri) {
    if (value is! Map<String, dynamic>) return null;
    final version = value['version'];
    final build = value['buildNumber'];
    final apk = value['apkUrl'];
    final notes = value['notes'] ?? '';
    if (version is! String ||
        !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version) ||
        build is! int ||
        build < 1 ||
        apk is! String ||
        apk.isEmpty ||
        notes is! String ||
        notes.length > 2000) {
      return null;
    }
    final uri = manifestUri.resolve(apk);
    if (uri.scheme != 'https' ||
        uri.origin != manifestUri.origin ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        !uri.path.endsWith('.apk')) {
      return null;
    }
    return AppRelease(
      version: version,
      buildNumber: build,
      apkUri: uri,
      notes: notes,
    );
  }
}
