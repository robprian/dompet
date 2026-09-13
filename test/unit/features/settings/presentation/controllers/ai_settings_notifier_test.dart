import 'package:dompet/core/services/secure_storage_service.dart';
import 'package:dompet/features/advisor/domain/ai/local_rule_provider.dart';
import 'package:dompet/features/settings/presentation/controllers/ai_settings_notifier.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _OfflineProvider extends LocalRuleProvider {
  _OfflineProvider({required this.reachable});

  final bool reachable;

  @override
  Future<bool> isAvailable() async => reachable;
}

void main() {
  test('local-rules connection test always succeeds without network', () async {
    final storage = _MockSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    final container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(SecureStorageService(storage))],
    );
    addTearDown(container.dispose);

    // Let the initial load settle before exercising the notifier.
    container.listen(aiSettingsProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final notifier = container.read(aiSettingsProvider.notifier);
    expect(
      await notifier.testConnection(
        providerId: 'local-rules',
        createProvider: (_) => _OfflineProvider(reachable: false),
      ),
      isTrue,
    );
  });

  test('custom provider test reports probe result', () async {
    final storage = _MockSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    final container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(SecureStorageService(storage))],
    );
    addTearDown(container.dispose);

    container.listen(aiSettingsProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final notifier = container.read(aiSettingsProvider.notifier);
    expect(
      await notifier.testConnection(
        providerId: 'custom',
        baseUrl: 'https://custom.example.com/v1',
        model: 'custom-model',
        apiKey: 'secret',
        createProvider: (config) {
          expect(config.baseUrl, 'https://custom.example.com/v1');
          expect(config.model, 'custom-model');
          expect(config.apiKey, 'secret');
          return _OfflineProvider(reachable: true);
        },
      ),
      isTrue,
    );
    expect(
      await notifier.testConnection(
        providerId: 'custom',
        createProvider: (_) => _OfflineProvider(reachable: false),
      ),
      isFalse,
    );
  });
}
