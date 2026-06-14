import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/scholarships/domain/scholarship_models.dart';
import 'package:admity/features/scholarships/presentation/scholarships_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Scholarship matcher: eligible-first, with honest reasons and a source link.
class ScholarshipsScreen extends ConsumerWidget {
  const ScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(scholarshipMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Стипендии')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: matches.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (i == matches.length) {
            return const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: SourceNote(
                text: 'Дедлайны и суммы меняются каждый год — всегда проверяй '
                    'актуальную дату у первоисточника.',
              ),
            );
          }
          return _MatchCard(match: matches[i]);
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final ScholarshipMatch match;

  Future<void> _openSource() async {
    final uri = Uri.tryParse(match.scholarship.sourceUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = match.scholarship;
    final color =
        match.eligible ? context.tokens.success : context.tokens.textMuted;

    return BentoCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${s.name} · ${s.country}',
                    style: context.text.titleSmall),
              ),
              Icon(
                match.eligible
                    ? Icons.check_circle_rounded
                    : Icons.do_not_disturb_on_rounded,
                color: color,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final reason in match.reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: context.text.bodySmall),
                  Expanded(
                    child: Text(reason, style: context.text.bodySmall),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openSource,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Первоисточник'),
            ),
          ),
        ],
      ),
    );
  }
}
