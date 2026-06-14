import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/gap_closer/presentation/gap_providers.dart';
import 'package:admity/features/gpa/presentation/gpa_providers.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/shared/models/profile.dart';
import 'package:admity/shared/widgets/admity_logo.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/selectable_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _interestOptions = [
  'Математика',
  'Биология',
  'Информатика',
  'Физика',
  'Химия',
  'Искусство',
  'Бизнес',
  'Языки',
  'Психология',
  'Спорт',
];

const _dreamPicks = [
  'Медицина',
  'IT',
  'Инженерия',
  'Бизнес',
  'Право',
  'Дизайн',
  'Наука',
  'Ещё не решил(а)',
];

/// The expanded, animated onboarding: welcome → identity → context → academics
/// (with the GPA helper) → goals → motivation. 11 steps, all skippable except a
/// name; data is saved into the [Profile] at the end.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 11;
  int _step = 0;

  final _nameController = TextEditingController();
  final _regionController = TextEditingController(text: 'Астана');
  final _dreamFieldController = TextEditingController();
  final _motivationController = TextEditingController();
  int _grade = 11;
  final _interests = <String>{};
  double _gpa = 4;
  final _geos = <TargetGeo>{};
  EnglishLevel? _englishLevel;
  int? _studyHours;
  BudgetSensitivity? _budget;
  bool _usesGpaCalculator = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    if (p.fullName != null) _nameController.text = p.fullName!;
    if (p.region != null) _regionController.text = p.region!;
    if (p.dreamField != null) _dreamFieldController.text = p.dreamField!;
    if (p.motivation != null) _motivationController.text = p.motivation!;
    _grade = p.grade ?? 11;
    _gpa = p.gpa ?? 4;
    _interests.addAll(p.interests);
    _geos.addAll(p.targetGeos);
    _englishLevel = p.englishLevel;
    _studyHours = p.studyHoursPerDay;
    _budget = p.budgetSensitivity;
    _usesGpaCalculator = p.usesGpaCalculator;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _dreamFieldController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else if (context.canPop()) {
      context.pop();
    }
  }

  Future<void> _openGpaHelper() async {
    await context.pushNamed(AppRoutes.gpaName);
    if (!mounted) return;
    final result = ref.read(gpaResultProvider);
    final subjects = ref.read(gpaSubjectsProvider);
    if (subjects.isNotEmpty) {
      setState(() {
        _gpa = result.scale5.clamp(2.0, 5.0);
        _usesGpaCalculator = true;
      });
    }
  }

  void _finish() {
    ref.read(profileProvider.notifier).save(
          Profile(
            fullName: _nameController.text.trim(),
            region: _regionController.text.trim(),
            grade: _grade,
            gpa: _gpa,
            interests: _interests,
            targetGeos: _geos,
            onboarded: true,
            locale: ref.read(profileProvider).locale,
            dreamField: _dreamFieldController.text.trim().isEmpty
                ? null
                : _dreamFieldController.text.trim(),
            englishLevel: _englishLevel,
            studyHoursPerDay: _studyHours,
            budgetSensitivity: _budget,
            motivation: _motivationController.text.trim().isEmpty
                ? null
                : _motivationController.text.trim(),
            usesGpaCalculator: _usesGpaCalculator,
          ),
        );
    ref.read(gapTasksProvider.notifier).regenerate();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  bool get _canAdvance {
    // Only the name step is lightly gated; everything else is skippable.
    if (_step == 1) return _nameController.text.trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (_step > 0 || context.canPop())
            ? IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: TweenAnimationBuilder<double>(
          tween: Tween(end: (_step + 1) / _steps),
          duration: AppDurations.medium,
          curve: Curves.easeOut,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.medium,
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  ),
                  child: SingleChildScrollView(
                    key: ValueKey(_step),
                    child: _stepContent(),
                  ),
                ),
              ),
              PrimaryButton(
                label: _step < _steps - 1 ? 'Далее' : 'Готово',
                onPressed: _canAdvance ? _next : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    return switch (_step) {
      0 => const _WelcomeStep(),
      1 => _Step(
          title: 'Давай познакомимся',
          subtitle: 'Как тебя зовут и в каком ты классе?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Имя'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Класс', style: context.text.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final g in [9, 10, 11, 12])
                    SelectableChip(
                      label: '$g класс',
                      selected: _grade == g,
                      onTap: () => setState(() => _grade = g),
                    ),
                ],
              ),
            ],
          ),
        ),
      2 => _Step(
          title: 'Откуда ты?',
          subtitle: 'Регион или город — для региональных грантов и контекста.',
          child: TextField(
            controller: _regionController,
            decoration: const InputDecoration(hintText: 'Регион / город'),
          ),
        ),
      3 => _Step(
          title: 'О чём ты мечтаешь?',
          subtitle: 'Направление или профессия — подберём вузы и проекты.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _dreamFieldController,
                decoration:
                    const InputDecoration(hintText: 'Например: Медицина'),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final pick in _dreamPicks)
                    SelectableChip(
                      label: pick,
                      selected: _dreamFieldController.text == pick,
                      onTap: () =>
                          setState(() => _dreamFieldController.text = pick),
                    ),
                ],
              ),
            ],
          ),
        ),
      4 => _Step(
          title: 'Что тебе интересно?',
          subtitle: 'Выбери несколько — подскажу направления и проекты.',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final option in _interestOptions)
                SelectableChip(
                  label: option,
                  selected: _interests.contains(option),
                  onTap: () => setState(() {
                    if (!_interests.add(option)) _interests.remove(option);
                  }),
                ),
            ],
          ),
        ),
      5 => _Step(
          title: 'Английский?',
          subtitle: 'Это влияет на выбор стран и программ.',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final level in EnglishLevel.values)
                SelectableChip(
                  label: level.label,
                  selected: _englishLevel == level,
                  onTap: () => setState(() => _englishLevel = level),
                ),
            ],
          ),
        ),
      6 => _Step(
          title: 'Твой средний балл',
          subtitle: 'Текущий или ожидаемый GPA (по 5-балльной шкале).',
          child: Column(
            children: [
              Text(
                _gpa.toStringAsFixed(1),
                style: context.text.displaySmall,
              ).animate(key: ValueKey(_gpa)).scale(
                    begin: const Offset(1.08, 1.08),
                    end: const Offset(1, 1),
                    duration: AppDurations.fast,
                  ),
              Slider(
                value: _gpa,
                min: 2,
                max: 5,
                divisions: 30,
                label: _gpa.toStringAsFixed(1),
                onChanged: (v) => setState(() {
                  _gpa = v;
                  _usesGpaCalculator = false;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _openGpaHelper,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Не знаю свой GPA — рассчитать'),
              ),
              if (_usesGpaCalculator)
                Text(
                  'Посчитано по таблице оценок',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.success),
                ),
            ],
          ),
        ),
      7 => _Step(
          title: 'Сколько готов(а) заниматься?',
          subtitle: 'Часов в день на подготовку — оценим реалистичный план.',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final h in [1, 2, 3, 4, 5])
                SelectableChip(
                  label: h == 5 ? '5+ ч' : '$h ч',
                  selected: _studyHours == h,
                  onTap: () => setState(() => _studyHours = h),
                ),
            ],
          ),
        ),
      8 => _Step(
          title: 'Что с бюджетом?',
          subtitle: 'Подберём гранты и стипендии под твою ситуацию.',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final b in BudgetSensitivity.values)
                SelectableChip(
                  label: b.label,
                  selected: _budget == b,
                  onTap: () => setState(() => _budget = b),
                ),
            ],
          ),
        ),
      9 => _Step(
          title: 'Куда метим?',
          subtitle: 'Выбери цели — можно несколько.',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final geo in TargetGeo.values)
                SelectableChip(
                  label: geo.label,
                  selected: _geos.contains(geo),
                  onTap: () => setState(() {
                    if (!_geos.add(geo)) _geos.remove(geo);
                  }),
                ),
            ],
          ),
        ),
      _ => _Step(
          title: 'Почему это важно для тебя?',
          subtitle: 'Пара слов — поможет Ералы писать эссе и мотивировать.',
          child: TextField(
            controller: _motivationController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Например: хочу стать врачом, чтобы помогать людям…',
            ),
          ),
        ),
    };
  }
}

/// The welcome step — a floating [AdmityLogo] and a one-line value prop.
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const AdmityLogo(size: 124)
            .animate()
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              duration: AppDurations.slow,
              curve: Curves.easeOutBack,
            )
            .fadeIn()
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -8,
              duration: 1600.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Привет! Я Ералы',
          textAlign: TextAlign.center,
          style: context.text.headlineMedium,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Помогу поступить честно и умно. Пройдём короткий опрос — '
          'и я подберу шансы, стипендии и план.',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium
              ?.copyWith(color: context.tokens.textMuted),
        ).animate().fadeIn(delay: 360.ms),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: context.text.headlineMedium)
            .animate()
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.18, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: context.text.bodyMedium
              ?.copyWith(color: context.tokens.textMuted),
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: AppDurations.medium)
            .slideY(begin: 0.18, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: AppSpacing.xl),
        child
            .animate()
            .fadeIn(delay: 160.ms, duration: AppDurations.medium)
            .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }
}
