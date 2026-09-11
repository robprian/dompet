import 'package:dompet/core/enums.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/settings/domain/ai_provider_settings.dart';
import 'package:dompet/features/transactions/data/transaction_ai_assist_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CategoryModel category(String id, String name, {CategoryType type = CategoryType.expense}) => CategoryModel(
    id: id,
    name: name,
    icon: 'tag',
    color: '#000000',
    type: type,
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
  );

  final categories = [
    category('c1', 'Food'),
    category('c2', 'Transport'),
  ];

  group('TransactionAiAssistService', () {
    test('is disabled for local-only provider', () {
      const settings = AIProviderSettings.defaults;
      const service = TransactionAiAssistService(settings: settings);
      expect(service.isEnabled, isFalse);
    });

    test('returns null when disabled', () async {
      const service = TransactionAiAssistService(settings: AIProviderSettings.defaults);
      final result = await service.suggestCategoryId(note: 'Kopi', categories: categories);
      expect(result, isNull);
    });

    test('returns null for empty note', () async {
      final settings = AIProviderSettings.defaults.copyWith(
        providerId: 'openai',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'key',
        model: 'gpt-4',
        privacyMode: PrivacyMode.allowExternal,
        explicitConsentGiven: true,
      );
      final service = TransactionAiAssistService(settings: settings);
      final result = await service.suggestCategoryId(note: '   ', categories: categories);
      expect(result, isNull);
    });

    test('is enabled for external provider with consent', () {
      final settings = AIProviderSettings.defaults.copyWith(
        providerId: 'openai',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'key',
        model: 'gpt-4',
        privacyMode: PrivacyMode.allowExternal,
        explicitConsentGiven: true,
      );
      final service = TransactionAiAssistService(settings: settings);
      expect(service.isEnabled, isTrue);
    });

    test('returns null when apiKey missing (no network call)', () async {
      final settings = AIProviderSettings.defaults.copyWith(
        providerId: 'openai',
        baseUrl: 'https://api.example.com/v1',
        model: 'gpt-4',
        privacyMode: PrivacyMode.allowExternal,
        explicitConsentGiven: true,
      );
      final service = TransactionAiAssistService(settings: settings);
      final result = await service.suggestCategoryId(note: 'Coffee', categories: categories);
      expect(result, isNull);
    });
  });
}
