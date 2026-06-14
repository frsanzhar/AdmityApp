import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/universities/domain/university.dart';
import 'package:admity/features/universities/presentation/universities_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Searchable explorer for KZ + world universities.
class UniversitiesScreen extends ConsumerWidget {
  const UniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universities = ref.watch(filteredUniversitiesProvider);
    final saved = ref.watch(collegeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Университеты')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xs,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск: вуз, страна, программа…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (q) =>
                  ref.read(uniSearchProvider.notifier).setQuery(q),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              itemCount: universities.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final uni = universities[i];
                return _UniCard(
                  uni: uni,
                  saved: saved.contains(uni.slug),
                  onToggle: () =>
                      ref.read(collegeListProvider.notifier).toggle(uni.slug),
                  onTap: () => context.pushNamed(
                    AppRoutes.universityDetailName,
                    pathParameters: {'slug': uni.slug},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UniCard extends StatelessWidget {
  const _UniCard({
    required this.uni,
    required this.saved,
    required this.onToggle,
    required this.onTap,
  });

  final University uni;
  final bool saved;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(uni.name, style: context.text.titleSmall),
                    ),
                    if (uni.isNeedBlindFullNeed) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: context.tokens.success,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${uni.country}'
                  '${uni.ranking != null ? ' · #${uni.ranking}' : ''}',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  uni.programs.take(3).join(' · '),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: saved ? context.colors.primary : context.tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
