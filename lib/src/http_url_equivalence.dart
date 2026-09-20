/// HTTP(S) identity: the same page should compare equal even when written
/// with a trailing slash, default port, or mixed-case host.
extension CanonicalHttpUrl on Uri {
  /// Scheme/host case folded, default ports dropped, trailing slash dropped
  /// except that `https://host` and `https://host/` both become `https://host`.
  Uri get asCanonicalHttpUrl {
    if (!_isHttpUrl) return this;

    var canonical = this;
    if (hasPort && _isDefaultHttpPort) {
      canonical = canonical.replace(port: 0);
    }

    final path = canonical.path;
    if (path == '/') {
      canonical = canonical.replace(path: '');
    } else if (path.length > 1 && path.endsWith('/')) {
      canonical = canonical.replace(path: path.substring(0, path.length - 1));
    }
    return canonical;
  }

  bool get _isHttpUrl =>
      host.isNotEmpty && (scheme == 'http' || scheme == 'https');

  bool get _isDefaultHttpPort =>
      (scheme == 'https' && port == 443) || (scheme == 'http' && port == 80);

  Uri get _withTrailingSlashOnPath {
    if (!_isHttpUrl) return this;
    final path = this.path;
    if (path.isEmpty || path == '/') return replace(path: '/');
    if (path.endsWith('/')) return this;
    return replace(path: '$path/');
  }
}

/// String form of [CanonicalHttpUrl] for stored URL text.
extension HttpUrlEquivalence on String {
  /// Canonical HTTP(S) identity string. Non-HTTP text is only trimmed.
  String get asCanonicalHttpUrl {
    final trimmed = trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri._isHttpUrl) return trimmed;
    return uri.asCanonicalHttpUrl.toString();
  }

  bool isSameHttpUrlAs(String other) =>
      asCanonicalHttpUrl == other.asCanonicalHttpUrl;

  /// Canonical form, trailing-slash twin, and the trimmed original when it
  /// still differs — enough to find a row stored before canonicalization.
  List<String> get equivalentHttpUrls {
    final trimmed = trim();
    final canonical = asCanonicalHttpUrl;
    final keys = <String>{canonical};
    final uri = Uri.tryParse(canonical);
    if (uri != null && uri._isHttpUrl) {
      keys.add(uri._withTrailingSlashOnPath.toString());
    }
    if (trimmed.isNotEmpty) keys.add(trimmed);
    return keys.toList();
  }
}
