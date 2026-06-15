import 'package:admity/core/l10n/locale_controller.dart';
import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/auth/presentation/auth_controller.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Profile + private "interesting facts about me" notes + language.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() {
    ref.read(notesProvider.notifier).add(_noteController.text);
    _noteController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notes = ref.watch(notesProvider);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.onboarding),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Изменить профиль',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const _AccountSection(),
          const SizedBox(height: AppSpacing.lg),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName?.isNotEmpty ?? false
                      ? profile.fullName!
                      : 'Без имени',
                  style: context.text.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                _row('Регион', profile.region ?? '—'),
                _row('Класс', profile.grade?.toString() ?? '—'),
                _row('GPA', profile.gpa?.toStringAsFixed(2) ?? '—'),
                _row(
                  'Цели',
                  profile.targetGeos.isEmpty
                      ? '—'
                      : profile.targetGeos.map((g) => g.label).join(', '),
                ),
                _row(
                  'Интересы',
                  profile.interests.isEmpty
                      ? '—'
                      : profile.interests.join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'Интересные факты обо мне',
            subtitle: 'Приватно. Ералы использует их для тем эссе и проектов.',
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _noteController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Например: чиню бабушкину швейную машинку…',
              suffixIcon: IconButton(
                onPressed: _addNote,
                icon: const Icon(Icons.add_circle_rounded),
              ),
            ),
            onSubmitted: (_) => _addNote(),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notes.isEmpty)
            Text(
              'Пока пусто. Добавь 3–5 фактов — это золото для эссе.',
              style: context.text.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          for (var i = 0; i < notes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: BentoCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(notes[i])),
                    IconButton(
                      onPressed: () =>
                          ref.read(notesProvider.notifier).removeAt(i),
                      icon: Icon(Icons.close_rounded, color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Язык'),
          const SizedBox(height: AppSpacing.sm),
          const _LanguageRow(),
          const SizedBox(height: AppSpacing.lg),
          const SourceNote(
            text: 'Тебе нет 18? Мы собираем минимум данных, храним их под '
                'защитой RLS и не передаём третьим лицам.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: context.text.bodySmall
                  ?.copyWith(color: context.tokens.textMuted),
            ),
          ),
          Expanded(child: Text(value, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}

/// Account entry: a sign-in card when signed out, or the signed-in email with
/// a sign-out button. This is the ONLY place that routes to the auth screen.
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value;
    final tokens = context.tokens;

    if (user == null) {
      return BentoCard(
        accent: tokens.info,
        onTap: () => context.push(AppRoutes.auth),
        child: Row(
          children: [
            Icon(Icons.login_rounded, color: context.colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Войти или зарегистрироваться',
                    style: context.text.titleMedium,
                  ),
                  Text(
                    'Через Apple или код на Gmail. Нужно, чтобы общаться с '
                    'Ералы и сохранить твой аккаунт.',
                    style: context.text.bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
          ],
        ),
      );
    }

    return BentoCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tokens.success.withValues(alpha: 0.18),
            child: Icon(Icons.check_rounded, color: tokens.success),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Вы вошли', style: context.text.labelMedium),
                Text(
                  user.email ?? 'Аккаунт',
                  style: context.text.titleMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await Supabase.instance.client.auth.signOut();
                // Clear the auth-flow state so the next visit to the sign-in
                // screen starts fresh instead of on the "signed in" step.
                ref.invalidate(authControllerProvider);
              } on Object {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Не удалось выйти. Проверь соединение.'),
                  ),
                );
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(localeControllerProvider.notifier);
    final current = ref.watch(localeControllerProvider)?.languageCode;
    final profileCtrl = ref.read(profileProvider.notifier);

    void set(String code) {
      controller.setLocale(Locale(code));
      profileCtrl.update((p) => p.copyWith(locale: code));
    }

    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (final (code, label) in const [
          ('kk', 'Қазақша'),
          ('ru', 'Русский'),
          ('en', 'English'),
        ])
          ChoiceChip(
            label: Text(label),
            selected: current == code,
            onSelected: (_) => set(code),
          ),
      ],
    );
  }
}
