import 'dart:async';

import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/quotes/presentation/quote_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A dashboard card showing the "Цитата дня": today's quote, its author and a
/// heart toggle to save it to favorites.
///
/// Safe to drop into a [Column] inside a [SingleChildScrollView]: it imposes no
/// unbounded constraints and sizes to its content.
class QuoteOfDayCard extends ConsumerWidget {
  /// Creates the quote-of-the-day card.
  const QuoteOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final textTheme = context.text;
    final quote = ref.watch(quoteOfDayProvider);
    final isFavorite = ref.watch(
      favoriteQuotesProvider.select(
        (favs) => favs.any((q) => q.text == quote.text),
      ),
    );

    return BentoCard(
      accent: tokens.xp,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 22,
                color: tokens.xp,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Цитата дня',
                  style: textTheme.labelLarge?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _FavoriteButton(
                isFavorite: isFavorite,
                onPressed: () {
                  unawaited(HapticFeedback.lightImpact());
                  ref.read(favoriteQuotesProvider.notifier).toggle(quote);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            quote.text,
            style: textTheme.titleMedium?.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: tokens.xp,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  quote.source == null
                      ? quote.author
                      : '${quote.author} · ${quote.source}',
                  style: textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppDurations.slow)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}

/// The heart toggle used in the card header; springs when favorited.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final icon = Icon(
      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      key: ValueKey<bool>(isFavorite),
      color: isFavorite ? tokens.danger : tokens.textMuted,
      size: 24,
    );

    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      tooltip: isFavorite
          ? 'Убрать из избранного'
          : 'Добавить в избранное',
      icon: isFavorite
          ? icon.animate(key: const ValueKey('fav-on')).scale(
                duration: AppDurations.fast,
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              )
          : icon,
    );
  }
}
