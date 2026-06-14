import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// The honesty banner shown next to any number that can go stale (scores,
/// deadlines, grant counts). Carries a year and a "verify at source" nudge —
/// a core product principle: never present a possibly-stale figure as fact.
class SourceNote extends StatelessWidget {
  const SourceNote({
    required this.text,
    this.year,
    super.key,
  });

  final String text;
  final int? year;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tokens.info.withValues(alpha: 0.1),
        borderRadius: AppRadii.brSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: tokens.info),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              year != null ? '$text (данные $year, проверь у первоисточника)'
                  : text,
              style: context.text.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
