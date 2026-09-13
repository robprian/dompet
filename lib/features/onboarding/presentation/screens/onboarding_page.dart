import 'package:dompet/app/router/router.dart';
import 'package:dompet/features/settings/domain/currency_model.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/features/settings/presentation/widgets/currency_search_list.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/dompet_brand_mark.dart';
import 'package:dompet/shared/widgets/dompet_header.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// First-run onboarding screen where user selects their base currency.
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final selectedCurrency = useState<CurrencyModel?>(null);
    final isSaving = useState(false);

    final availableCurrenciesFuture = useFuture(
      useMemoized(() => ref.read(settingsProvider.notifier).getAvailableCurrencies()),
    );
    final currencies = availableCurrenciesFuture.data ?? <CurrencyModel>[];
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FCard(
          child: Padding(
            padding: EdgeInsets.all(theme.style.app.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DompetBrandMark(size: 56, animated: true),
                SizedBox(width: theme.style.app.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.onboarding.chooseYourBaseCurrency, style: theme.typography.titleCard),
                      SizedBox(height: theme.style.app.xs),
                      Text(
                        t
                            .onboarding
                            .thisCurrencyWillBeUsedForAllAccountsPocketsAndTransactionsYouCanChangeThisLaterInSettings,
                        style: theme.typography.bodyPrimary.copyWith(color: theme.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: availableCurrenciesFuture.hasError
              ? Center(child: Text(availableCurrenciesFuture.error.toString()))
              : currencies.isEmpty
              ? const Center(child: FCircularProgress())
              : CurrencySearchList(
                  currencies: currencies,
                  selectedCurrency: selectedCurrency.value,
                  onSelect: (currency) => selectedCurrency.value = currency,
                ),
        ),
        const SizedBox(height: 12),
        FButton(
          onPress: selectedCurrency.value == null || isSaving.value
              ? null
              : () async {
                  isSaving.value = true;
                  final saved = await ref.read(settingsProvider.notifier).setBaseCurrency(selectedCurrency.value!.id);
                  if (!context.mounted) return;
                  isSaving.value = false;
                  if (saved) const DashboardRoute().go(context);
                },
          child: isSaving.value ? const FCircularProgress() : Text(t.onboarding.continueWithCurrency),
        ),
        const SizedBox(height: 20),
      ],
    );

    return FScaffold(
      header: DompetHeader(
        leading: const DompetBrandMark(size: 40, animated: true),
        subtitle: t.app.name,
        title: t.onboarding.chooseYourBaseCurrency,
      ),
      child: MediaQuery.disableAnimationsOf(context)
          ? content
          : content.animate().fadeIn(duration: 420.ms).slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
