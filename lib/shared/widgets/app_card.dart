import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// White card with [AppTokens.radiusLg] corners and a soft [AppColors.cardShadow].
///
/// Padding defaults to [AppTokens.cardPadding] (16 px) on all sides.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final cardDecoration = BoxDecoration(
      color: color ?? AppColors.white,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      boxShadow: tokens.cardShadow,
    );

    final content = DecoratedBox(
      decoration: cardDecoration,
      child: Padding(
        padding: padding ?? EdgeInsets.all(tokens.cardPadding),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
