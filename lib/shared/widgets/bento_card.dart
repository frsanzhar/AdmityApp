import 'dart:async';

import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The core surface of the app: a soft, rounded, branded-shadow card used to
/// build bento-grid dashboards. Optionally tappable (adds light haptics).
class BentoCard extends StatelessWidget {
  const BentoCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.accent,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Overrides the raised surface color.
  final Color? color;

  /// Optional accent stripe drawn down the leading edge.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? tokens.surfaceRaised,
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: accent != null
            ? Border(left: BorderSide(color: accent!, width: 4))
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppRadii.brLg,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap!.call();
        },
        child: content,
      ),
    );
  }
}
