import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';

/// Reusable Dompet brand mark (logo + optional wordmark).
///
/// The in-app branding previously only appeared on the About page. This widget
/// centralises the logo so headers, onboarding, and empty states can render a
/// consistent brand identity without duplicating asset paths or sizing.
class DompetBrandMark extends StatelessWidget {
  /// Creates a [DompetBrandMark].
  const DompetBrandMark({
    this.size = 28,
    this.radius,
    this.padding,
    super.key,
  });

  /// The logo edge length in logical pixels.
  final double size;

  /// Corner radius applied to the logo tile. Defaults to a rounded square.
  final BorderRadius? radius;

  /// Optional inner padding around the logo artwork.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveRadius = radius ?? BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: effectiveRadius,
        border: Border.all(color: theme.colors.border, width: 0.5),
      ),
      padding: padding ?? EdgeInsets.all(size * 0.12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
