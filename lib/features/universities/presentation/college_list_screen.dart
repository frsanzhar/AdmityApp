import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/universities/presentation/universities_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The student's saved college list.
class CollegeListScreen extends ConsumerWidget {
  const CollegeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(collegeListProvider);
    final universities =
        ref.watch(universitiesProvider).where((u) => saved.contains(u.slug)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Мой список вузов')),
      body: universities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Пока пусто. Добавляй вузы из раздела «Университеты» — '
                  'закладкой.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.tokens.textMuted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: universities.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final uni = universities[i];
                return BentoCard(
                  onTap: () => context.pushNamed(
                    AppRoutes.universityDetailName,
                    pathParameters: {'slug': uni.slug},
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(uni.name, style: context.text.titleSmall),
                            Text(
                              uni.country,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.tokens.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(collegeListProvider.notifier)
                            .toggle(uni.slug),
                        icon: const Icon(Icons.bookmark_remove_rounded),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
