import 'package:dompet/core/services/github_release_provider.dart';
import 'package:dompet/core/services/github_release_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('provider can be overridden for offline checks', () async {
    final container = ProviderContainer(
      overrides: [
        githubReleaseServiceProvider.overrideWithValue(
          GithubReleaseService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(githubReleaseServiceProvider), isA<GithubReleaseService>());
  });
}
