import 'package:dompet/features/settings/presentation/controllers/ai_settings_notifier.dart';
import 'package:dompet/features/transactions/data/transaction_ai_assist_service.dart';
import 'package:riverpod/riverpod.dart';

/// Provides the optional AI category-suggestion helper for the transaction form.
///
/// Reads the current AI settings so the feature stays dormant in the default
/// local-only mode and only activates when an external provider is configured
/// and consented to by the user.
final transactionAiAssistServiceProvider = Provider<TransactionAiAssistService>((ref) {
  final settings = ref.watch(aiSettingsProvider);
  return TransactionAiAssistService(settings: settings);
});
