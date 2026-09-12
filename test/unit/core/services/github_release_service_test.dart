import 'package:dompet/core/services/github_release_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses the latest GitHub release', () async {
    final client = MockClient((request) async {
      return http.Response(
        '{"tag_name":"v2.1.0","html_url":"https://github.com/robprian/dompet/releases/tag/v2.1.0"}',
        200,
      );
    });

    final result = await GithubReleaseService(client: client).fetchLatest();

    expect(result?.tagName, 'v2.1.0');
    expect(result?.url.path, '/robprian/dompet/releases/tag/v2.1.0');
  });

  test('returns null for an unavailable release endpoint', () async {
    final client = MockClient((request) async => http.Response('', 503));

    final result = await GithubReleaseService(client: client).fetchLatest();

    expect(result, isNull);
  });
}
