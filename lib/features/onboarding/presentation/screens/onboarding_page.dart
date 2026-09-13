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

/// First-run onboarding wizard guiding the user through a welcome step and
/// base-currency selection before the ledger is unlocked.
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final step = useState(0);
    final selectedCurrency = useState<CurrencyModel?>(null);
    final isSaving = useState(false);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final reloadToken = useState(0);

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final availableCurrenciesFuture = useFuture(
      useMemoized(
        () => ref.read(settingsProvider.notifier).getAvailableCurrencies(),
        [reloadToken.value],
      ),
    );
    final allCurrencies = availableCurrenciesFuture.data ?? <CurrencyModel>[];
    final query = searchQuery.value.trim().toLowerCase();
    final currencies = query.isEmpty
        ? allCurrencies
        : allCurrencies
              .where(
                (c) => c.code.toLowerCase().contains(query) || c.name.toLowerCase().contains(query),
              )
              .toList();

    Future<void> finish() async {
      final currency = selectedCurrency.value;
      if (currency == null || isSaving.value) return;
      isSaving.value = true;
      final saved = await ref.read(settingsProvider.notifier).setBaseCurrency(currency.id);
      if (!context.mounted) return;
      isSaving.value = false;
      if (saved) const DashboardRoute().go(context);
    }

    final isWelcomeStep = step.value == 0;

    return FScaffold(
      header: DompetHeader(
        leading: const DompetBrandMark(size: 40, animated: true),
        subtitle: t.app.name,
        title: isWelcomeStep ? t.onboarding.welcomeTitle : t.onboarding.chooseYourBaseCurrency,
        showBack: !isWelcomeStep,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Progress indicator ───────────────────────────────────────────
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step.value ? theme.colors.primary : theme.colors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i == 0) const SizedBox(width: 8),
              ],
            ],
          ).animate().fadeIn(duration: 320.ms),
          const SizedBox(height: 20),

          // ── Step body ────────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: isWelcomeStep
                  ? const _WelcomeStep(key: ValueKey('welcome'))
                  : Column(
                      key: const ValueKey('currency'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTextField(
                          hint: t.settings.search,
                          control: FTextFieldControl.managed(controller: searchController),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: availableCurrenciesFuture.hasError
                              ? _CurrencyError(onRetry: () => reloadToken.value++)
                              : allCurrencies.isEmpty
                              ? const Center(child: FCircularProgress())
                              : CurrencySearchList(
                                  currencies: currencies,
                                  selectedCurrency: selectedCurrency.value,
                                  onSelect: (currency) => selectedCurrency.value = currency,
                                ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Actions ──────────────────────────────────────────────────────
          if (isWelcomeStep)
            FButton(
              key: const Key('onboarding-get-started'),
              onPress: () => step.value = 1,
              child: Text(t.onboarding.getStarted),
            )
          else
            FButton(
              key: const Key('onboarding-continue'),
              onPress: selectedCurrency.value == null || isSaving.value ? null : finish,
              child: isSaving.value ? const FCircularProgress() : Text(t.onboarding.continueWithCurrency),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Hero welcome step introducing the privacy-first promise.
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final highlights = [
      (icon: FPhosphorIcons.shieldCheck, title: t.onboarding.privateTitle, body: t.onboarding.privateDescription),
      (icon: FPhosphorIcons.cloudSlash, title: t.onboarding.offlineTitle, body: t.onboarding.offlineDescription),
      (icon: FPhosphorIcons.chartLineUp, title: t.onboarding.clarityTitle, body: t.onboarding.clarityDescription),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: DompetBrandMark(size: 96, animated: true),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Text(
            t.onboarding.welcomeTitle,
            textAlign: TextAlign.center,
            style: theme.typography.display.lg.copyWith(
              color: theme.colors.foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 10),
          Text(
            t.onboarding.welcomeDescription,
            textAlign: TextAlign.center,
            style: theme.typography.bodyPrimary.copyWith(color: theme.colors.mutedForeground),
          ).animate().fadeIn(duration: 400.ms, delay: 140.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 24),
          for (var i = 0; i < highlights.length; i++) ...[
            _HighlightTile(
              icon: highlights[i].icon,
              title: highlights[i].title,
              body: highlights[i].body,
            ).animate().fadeIn(duration: 380.ms, delay: (180 + i * 70).ms).slideY(begin: 0.06, end: 0),
            if (i != highlights.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Single benefit row used by the welcome step.
class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.12),
                borderRadius: theme.style.borderRadius.md,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 20, color: theme.colors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.bodySecondary.copyWith(
                      color: theme.colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.typography.caption.copyWith(color: theme.colors.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry affordance shown when the currency catalog fails to load.
class _CurrencyError extends StatelessWidget {
  const _CurrencyError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FPhosphorIcons.warningCircle, size: 32, color: theme.colors.mutedForeground),
          const SizedBox(height: 12),
          Text(
            t.onboarding.currenciesFailed,
            textAlign: TextAlign.center,
            style: theme.typography.bodyPrimary.copyWith(color: theme.colors.mutedForeground),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: FButtonVariant.outline,
            onPress: onRetry,
            child: Text(t.onboarding.retry),
          ),
        ],
      ),
    );
  }
}
