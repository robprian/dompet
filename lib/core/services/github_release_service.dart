import 'dart:convert';

import 'package:http/http.dart' as http;

/// Release metadata returned by the GitHub Releases API.
class GithubReleaseInfo {
  /// Creates release metadata.
  const GithubReleaseInfo({required this.tagName, required this.url});

  /// Release tag, for example `v2.1.0`.
  final String tagName;

  /// Browser URL for the release.
  final Uri url;
}

/// Reads the latest public Dompet release from GitHub.
class GithubReleaseService {
  /// Creates a service using [client].
  GithubReleaseService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns the latest release, or null when GitHub is unavailable.
  Future<GithubReleaseInfo?> fetchLatest() async {
    try {
      final response = await _client.get(
        Uri.parse('https://api.github.com/repos/robprian/dompet/releases/latest'),
        headers: const {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Object;
      if (decoded is! Map<String, Object?>) return null;
      final tagName = decoded['tag_name'];
      final htmlUrl = decoded['html_url'];
      if (tagName is! String || htmlUrl is! String) return null;

      final url = Uri.tryParse(htmlUrl);
      if (url == null) return null;
      return GithubReleaseInfo(tagName: tagName, url: url);
    } on Object {
      return null;
    }
  }
}
