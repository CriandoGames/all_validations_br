const Set<String> _allowedUrlSchemes = {'http', 'https', 'ftp'};

/// Validates an absolute URL using the public schemes supported by the package.
bool isAllowedUrl(String value) {
  if (value.isEmpty || RegExp(r'\s').hasMatch(value)) return false;

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;

  return _allowedUrlSchemes.contains(uri.scheme.toLowerCase());
}
