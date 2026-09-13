import 'package:flutter/material.dart';

/// Reusable Dompet brand mark (logo + optional wordmark).
///
/// Renders the raw logo artwork exactly as shipped in
/// `assets/images/logo.png`, without tint, background, border, or padding.
/// Callers needing a decorated tile should add their own container — the brand
/// mark itself stays as-is everywhere (splash, headers, onboarding).
class DompetBrandMark extends StatelessWidget {
  /// Creates a [DompetBrandMark].
  const DompetBrandMark({this.size = 28, this.animated = false, super.key});

  /// The logo edge length in logical pixels.
  final double size;

  /// Whether the mark fades in once when first rendered.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final Widget mark = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (!animated || MediaQuery.disableAnimationsOf(context)) return mark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      child: mark,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 12 * (1 - value)), child: child),
      ),
    );
  }
}
