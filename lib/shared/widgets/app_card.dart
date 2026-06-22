import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// White card with [AppTokens.radiusLg] corners and a soft [AppColors.cardShadow].
///
/// Padding defaults to [AppTokens.cardPadding] (16 px) on all sides.
///
/// ## Animation (non-breaking addition)
/// When [animateIn] is true the card fades and slides up on first mount.
/// Suppressed automatically when `MediaQuery.disableAnimations` is true.
/// Default is `false` so all existing call sites are unaffected.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.color,
    this.onTap,
    // Entrance animation — opt-in, default false (non-breaking).
    this.animateIn = false,
    this.animateDelay = Duration.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  /// When true the card animates in (fade + slight upward slide) on mount.
  /// Existing call sites that omit this parameter are unaffected.
  final bool animateIn;

  /// Optional stagger delay for the entrance animation.
  final Duration animateDelay;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final disableAnim = MediaQuery.of(context).disableAnimations;

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

    Widget tappable = content;
    if (onTap != null) {
      tappable = GestureDetector(onTap: onTap, child: content);
    }

    // Apply entrance animation only when opted in and motion is allowed.
    if (animateIn && !disableAnim) {
      return tappable
          .animate()
          .fade(
            duration: const Duration(milliseconds: 350),
            delay: animateDelay,
            curve: Curves.easeOutCubic,
          )
          .slideY(
            begin: 0.10,
            end: 0,
            duration: const Duration(milliseconds: 350),
            delay: animateDelay,
            curve: Curves.easeOutCubic,
          );
    }

    return tappable;
  }
}
