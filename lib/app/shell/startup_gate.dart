import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/shared/widgets/dompet_brand_mark.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Gate shown while settings and lock state resolve on startup.
class StartupGate extends ConsumerWidget {
  const StartupGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    if (settingsState.settings != null || (settingsState.error != null && !settingsState.isLoading)) {
      return child;
    }
    const splash = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DompetBrandMark(size: 72, animated: true),
          SizedBox(height: 16),
          FCircularProgress(),
        ],
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return splash;
    return splash.animate().fadeIn(duration: 320.ms).scale(begin: const Offset(0.96, 0.96));
  }
}
