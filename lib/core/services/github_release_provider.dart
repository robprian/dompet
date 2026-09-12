import 'package:dompet/core/services/github_release_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the GitHub release checker used by the About screen.
final githubReleaseServiceProvider = Provider<GithubReleaseService>((ref) {
  return GithubReleaseService();
});

/// Loads the latest release without making app startup depend on the network.
final latestGithubReleaseProvider = FutureProvider<GithubReleaseInfo?>((ref) {
  return ref.watch(githubReleaseServiceProvider).fetchLatest();
});
