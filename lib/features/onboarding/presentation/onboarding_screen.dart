/// Animated onboarding flow — Brilliant/Duolingo-style.
///
/// 14 steps: 5 feature intro slides + data-collection steps + reveal + completion.
/// Each step animates in with flutter_animate (fade + slide).
/// On finish: saves profile with onboardingComplete=true → /home.
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _gradeOptions = ['9 класс', '10 класс', '11 класс', 'Бакалавриат'];

const _cityOptions = [
  'Алматы',
  'Астана',
  'Шымкент',
  'Қарағанды',
  'Атырау',
  'Өскемен',
  'Тараз',
  'Павлодар',
  'Семей',
  'Актобе',
];

const _interestOptions = [
  'Математика',
  'Физика',
  'Химия',
  'Биология',
  'IT и программирование',
  'Экономика',
  'Право',
  'Медицина',
  'Дизайн',
  'Искусство',
  'Спорт',
  'Языки',
  'История',
  'Психология',
];

/// Animated onboarding / intro (Brilliant/Duolingo-style).
///
/// Simultaneously introduces Admity features and collects student data into
/// StudentProfile. On completion saves profile with onboardingComplete=true.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  static const _totalSteps = 14;

  // Data collection state
  String? _city;
  String? _grade;
  int? _dailyGoalMinutes;
  String? _schedule;

  final _cityCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();
  bool _hasIelts = false;
  bool _hasSat = false;
  bool _hasToefl = false;
  final _ieltsCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  final _toeflCtrl = TextEditingController();
  final Set<String> _interests = {};

  @override
  void dispose() {
    _cityCtrl.dispose();
    _gpaCtrl.dispose();
    _ieltsCtrl.dispose();
    _satCtrl.dispose();
    _toeflCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    final currentProfile = ref.read(profileProvider).profile;
    final cityValue = _cityCtrl.text.trim().isNotEmpty
        ? _cityCtrl.text.trim()
        : _city;
    final updated = currentProfile.copyWith(
      city: cityValue,
      grade: _grade,
      gpa: _gpaCtrl.text.trim().isEmpty ? null : _gpaCtrl.text.trim(),
      interests: _interests.toList(),
      ieltsScore: _hasIelts && _ieltsCtrl.text.trim().isNotEmpty
          ? _ieltsCtrl.text.trim()
          : null,
      satScore: _hasSat && _satCtrl.text.trim().isNotEmpty
          ? _satCtrl.text.trim()
          : null,
      toeflScore: _hasToefl && _toeflCtrl.text.trim().isNotEmpty
          ? _toeflCtrl.text.trim()
          : null,
      dailyGoalMinutes: _dailyGoalMinutes,
      schedule: _schedule,
      onboardingComplete: true,
    );
    await ref.read(profileProvider.notifier).saveProfile(updated);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator + back button
            _ProgressBar(step: _step, tokens: tokens, onPrev: _prev),

            // Step content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(context, tokens),
                ),
              ),
            ),

            // Navigation buttons
            _NavButtons(step: _step, onNext: _next, tokens: tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppTokens tokens) {
    switch (_step) {
      case 0:
        return _WelcomeStep(tokens: tokens);
      case 1:
        return _FeatureStep(
          tokens: tokens,
          title: 'Честный прогноз шансов',
          subtitle:
              'Узнай реальные шансы поступления на основе ЕНТ, ГПА и Common Data Set — без завышенных обещаний.',
          icon: Icons.analytics_outlined,
          useTopicDiagram: true,
        );
      case 2:
        return _FeatureStep(
          tokens: tokens,
          title: 'Курсы и уроки',
          subtitle:
              'Короткие, геймифицированные уроки в стиле Brilliant. Стрик, XP, уровни — учись каждый день.',
          icon: Icons.school_outlined,
          useTopicDiagram: true,
        );
      case 3:
        return _FeatureStep(
          tokens: tokens,
          title: 'Ералы — твой AI-ментор',
          subtitle:
              'Дружелюбный наставник, который направляет и подсказывает, помогает спланировать подготовку к экзаменам.',
          icon: Icons.psychology_outlined,
          useMascot: true,
        );
      case 4:
        return _FeatureStep(
          tokens: tokens,
          title: 'Возможности и стипендии',
          subtitle:
              'Стипендии, университеты, мероприятия и идеи проектов — подобраны под твой профиль.',
          icon: Icons.star_outline_rounded,
          useTopicDiagram: true,
        );
      case 5:
        return _CityStep(
          tokens: tokens,
          controller: _cityCtrl,
          city: _city,
          onCityChanged: (v) => setState(() => _city = v),
        );
      case 6:
        return _GradeStep(
          tokens: tokens,
          selected: _grade,
          onSelect: (g) => setState(() => _grade = g),
        );
      case 7:
        return _GpaStep(tokens: tokens, controller: _gpaCtrl);
      case 8:
        return _InterestsStep(
          tokens: tokens,
          selected: _interests,
          onToggle: (interest) {
            setState(() {
              if (_interests.contains(interest)) {
                _interests.remove(interest);
              } else {
                _interests.add(interest);
              }
            });
          },
        );
      case 9:
        return _ExamsStep(
          tokens: tokens,
          hasIelts: _hasIelts,
          hasSat: _hasSat,
          hasToefl: _hasToefl,
          ieltsCtrl: _ieltsCtrl,
          satCtrl: _satCtrl,
          toeflCtrl: _toeflCtrl,
          onToggleIelts: (v) => setState(() => _hasIelts = v),
          onToggleSat: (v) => setState(() => _hasSat = v),
          onToggleToefl: (v) => setState(() => _hasToefl = v),
        );
      case 10:
        return _DailyGoalStep(
          tokens: tokens,
          selected: _dailyGoalMinutes,
          onSelect: (v) => setState(() => _dailyGoalMinutes = v),
        );
      case 11:
        return _ScheduleStep(
          tokens: tokens,
          selected: _schedule,
          onSelect: (v) => setState(() => _schedule = v),
        );
      case 12:
        return _PlanRevealStep(tokens: tokens, onRevealComplete: _next);
      case 13:
        return _CompletionStep(tokens: tokens);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.step,
    required this.tokens,
    required this.onPrev,
  });

  final int step;
  final AppTokens tokens;
  final VoidCallback onPrev;

  // Only shown for steps 0..11 (12 segments)
  static const _totalSegments = 12;

  @override
  Widget build(BuildContext context) {
    // Steps 12 and 13: hide the progress bar entirely
    if (step >= 12) return const SizedBox.shrink();

    final segmentsRow = Row(
      children: List.generate(_totalSegments, (i) {
        final filled = i <= step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i < _totalSegments - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapMd,
        tokens.screenPadding,
        tokens.gapSm,
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            GestureDetector(
              onTap: onPrev,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: segmentsRow),
        ],
      ),
    );
  }
}

// ── Nav buttons ───────────────────────────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.step,
    required this.onNext,
    required this.tokens,
  });

  final int step;
  final VoidCallback onNext;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    // Steps 12+ have no nav buttons (reveal auto-advances; completion has
    // FeaturedButton inside the step itself).
    if (step >= 12) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapSm,
        tokens.screenPadding,
        tokens.gapXl,
      ),
      child: PrimaryButton(label: 'Далее', onPressed: onNext),
    );
  }
}

// ── Step 0: Welcome ───────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: const MascotSlot(tag: 'onboarding_welcome'),
          ),
          SizedBox(height: tokens.gapXl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: Text(
              'Добро пожаловать в Admity',
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animatedWidget(
            noAnim: noAnim,
            delay: 350,
            child: Text(
              'Честный прогноз поступления, AI-ментор Ералы, курсы и стипендии — всё в одном приложении.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 500,
            child: const _FeaturePill(
              icon: Icons.analytics_outlined,
              label: 'Честные шансы',
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 600,
            child: const _FeaturePill(
              icon: Icons.school_outlined,
              label: 'Геймифицированные курсы',
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 700,
            child: const _FeaturePill(
              icon: Icons.psychology_outlined,
              label: 'AI-ментор Ералы',
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 800,
            child: const _FeaturePill(
              icon: Icons.star_outline_rounded,
              label: 'Стипендии и возможности',
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

Widget _animatedWidget({
  required bool noAnim,
  required int delay,
  required Widget child,
}) {
  if (noAnim) return child;
  return child
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: delay),
        duration: 400.ms,
      )
      .slideY(begin: 0.15, end: 0, duration: 400.ms);
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

// ── Steps 1-4: Feature intro ──────────────────────────────────────────────────

class _FeatureStep extends StatelessWidget {
  const _FeatureStep({
    required this.tokens,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.useTopicDiagram = false,
    this.useMascot = false,
  });

  final AppTokens tokens;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool useTopicDiagram;
  final bool useMascot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: useMascot
                ? const MascotSlot(
                    size: 110,
                    tag: 'onboarding_feature',
                    state: MascotState.happy,
                  )
                : useTopicDiagram
                ? const TopicDiagramSlot(size: 110)
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusXl),
                    ),
                    child: Icon(icon, size: 40, color: AppColors.primary),
                  ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 150,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animatedWidget(
            noAnim: noAnim,
            delay: 250,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 5: City ──────────────────────────────────────────────────────────────

class _CityStep extends StatelessWidget {
  const _CityStep({
    required this.tokens,
    required this.controller,
    required this.city,
    required this.onCityChanged,
  });

  final AppTokens tokens;
  final TextEditingController controller;
  final String? city;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Из какого ты города?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Поможет найти события и возможности рядом.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: TextField(
              controller: controller,
              onChanged: onCityChanged,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Введи название города',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceTint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.gapLg),
          _animatedWidget(
            noAnim: noAnim,
            delay: 300,
            child: Text(
              'Или выбери:',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 400,
            child: Wrap(
              spacing: tokens.gapSm,
              runSpacing: tokens.gapSm,
              children: _cityOptions.map((c) {
                final isSelected = city == c || controller.text == c;
                return GestureDetector(
                  onTap: () {
                    controller.text = c;
                    onCityChanged(c);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      c,
                      style: textTheme.labelLarge?.copyWith(
                        color: isSelected ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 6: Grade ─────────────────────────────────────────────────────────────

class _GradeStep extends StatelessWidget {
  const _GradeStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Твой класс / ступень',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Это поможет нам подобрать подходящие курсы и контент.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: Wrap(
              spacing: tokens.gapSm,
              runSpacing: tokens.gapSm,
              children: _gradeOptions.map((g) {
                final isSelected = selected == g;
                return GestureDetector(
                  onTap: () => onSelect(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      g,
                      style: textTheme.labelLarge?.copyWith(
                        color: isSelected ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 7: GPA ───────────────────────────────────────────────────────────────

class _GpaStep extends StatelessWidget {
  const _GpaStep({required this.tokens, required this.controller});
  final AppTokens tokens;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Средний балл / ГПА',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Введи свой средний балл (например: 4.8 или 90). Можешь пропустить.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Например: 4.8',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceTint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 8: Interests ─────────────────────────────────────────────────────────

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({
    required this.tokens,
    required this.selected,
    required this.onToggle,
  });

  final AppTokens tokens;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Интересы и увлечения',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Выбери всё, что тебе интересно. Это поможет подобрать контент.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: Wrap(
              spacing: tokens.gapSm,
              runSpacing: tokens.gapSm,
              children: _interestOptions.map((interest) {
                final isSelected = selected.contains(interest);
                return GestureDetector(
                  onTap: () => onToggle(interest),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: textTheme.labelLarge?.copyWith(
                        color: isSelected ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 9: Exams ─────────────────────────────────────────────────────────────

class _ExamsStep extends StatelessWidget {
  const _ExamsStep({
    required this.tokens,
    required this.hasIelts,
    required this.hasSat,
    required this.hasToefl,
    required this.ieltsCtrl,
    required this.satCtrl,
    required this.toeflCtrl,
    required this.onToggleIelts,
    required this.onToggleSat,
    required this.onToggleToefl,
  });

  final AppTokens tokens;
  final bool hasIelts;
  final bool hasSat;
  final bool hasToefl;
  final TextEditingController ieltsCtrl;
  final TextEditingController satCtrl;
  final TextEditingController toeflCtrl;
  final ValueChanged<bool> onToggleIelts;
  final ValueChanged<bool> onToggleSat;
  final ValueChanged<bool> onToggleToefl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Стандартизированные экзамены',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Отметь экзамены, которые ты сдавал(а), и введи баллы.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: _ExamToggleRow(
              label: 'IELTS',
              active: hasIelts,
              onToggle: onToggleIelts,
              controller: ieltsCtrl,
              hint: 'Например: 7.0',
              tokens: tokens,
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animatedWidget(
            noAnim: noAnim,
            delay: 300,
            child: _ExamToggleRow(
              label: 'SAT',
              active: hasSat,
              onToggle: onToggleSat,
              controller: satCtrl,
              hint: 'Например: 1400',
              tokens: tokens,
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animatedWidget(
            noAnim: noAnim,
            delay: 400,
            child: _ExamToggleRow(
              label: 'TOEFL',
              active: hasToefl,
              onToggle: onToggleToefl,
              controller: toeflCtrl,
              hint: 'Например: 100',
              tokens: tokens,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

class _ExamToggleRow extends StatelessWidget {
  const _ExamToggleRow({
    required this.label,
    required this.active,
    required this.onToggle,
    required this.controller,
    required this.hint,
    required this.tokens,
  });

  final String label;
  final bool active;
  final ValueChanged<bool> onToggle;
  final TextEditingController controller;
  final String hint;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(tokens.cardPadding),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                label,
                style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onToggle(!active),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: active
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (active) ...[
            SizedBox(height: tokens.gapMd),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step 10: Daily Goal ───────────────────────────────────────────────────────

class _DailyGoalStep extends StatelessWidget {
  const _DailyGoalStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const List<({int minutes, String label, String unit, String subtitle})>
  _goals = [
    (
      minutes: 10,
      label: '10',
      unit: 'мин',
      subtitle: 'Немного, но каждый день',
    ),
    (minutes: 20, label: '20', unit: 'мин', subtitle: 'Стабильный прогресс'),
    (minutes: 30, label: '30', unit: 'мин', subtitle: 'Хороший темп'),
    (minutes: 60, label: '60', unit: 'мин', subtitle: 'Погружение'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Сколько времени на учёбу?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Выбери ежедневную цель. Лучше меньше, но регулярно.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _goals.map((goal) {
                final isSelected = selected == goal.minutes;
                return GestureDetector(
                  onTap: () => onSelect(goal.minutes),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: goal.label,
                                style: textTheme.headlineLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.ink,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: ' ${goal.unit}',
                                style: textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.white.withValues(alpha: 0.85)
                                      : AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppColors.white.withValues(alpha: 0.85)
                                : AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 11: Schedule ─────────────────────────────────────────────────────────

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const List<
    ({String value, String emoji, String label, String subtitle})
  >
  _schedules = [
    (value: 'morning', emoji: '🌅', label: 'Утро', subtitle: 'До начала дня'),
    (value: 'day', emoji: '☀', label: 'День', subtitle: 'В свободное время'),
    (value: 'evening', emoji: '🌙', label: 'Вечер', subtitle: 'После учёбы'),
    (
      value: 'flexible',
      emoji: '⚡',
      label: 'Когда получится',
      subtitle: 'Гибкий график',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: Text(
              'Когда удобнее учиться?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animatedWidget(
            noAnim: noAnim,
            delay: 100,
            child: Text(
              'Выбери наиболее удобное время.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 200,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _schedules.map((s) {
                final isSelected = selected == s.value;
                return GestureDetector(
                  onTap: () => onSelect(s.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: isSelected ? AppColors.white : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppColors.white.withValues(alpha: 0.85)
                                : AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 12: Plan reveal ──────────────────────────────────────────────────────

class _PlanRevealStep extends StatefulWidget {
  const _PlanRevealStep({
    required this.tokens,
    required this.onRevealComplete,
  });

  final AppTokens tokens;
  final VoidCallback onRevealComplete;

  @override
  State<_PlanRevealStep> createState() => _PlanRevealStepState();
}

class _PlanRevealStepState extends State<_PlanRevealStep> {
  int _visibleCards = 0;
  bool _showLoader = false;
  final List<Timer> _timers = [];

  static const List<
    ({String title, String subtitle, IconData icon, Color color})
  >
  _revealCards = [
    (
      title: 'У нас есть всё',
      subtitle: 'Тысячи задач, курсы и ментор',
      icon: Icons.auto_awesome,
      color: AppColors.primary,
    ),
    (
      title: 'Граф знаний',
      subtitle: 'Видишь, что знаешь и куда расти',
      icon: Icons.hub_outlined,
      color: AppColors.accentLime,
    ),
    (
      title: 'Я знаю, с чего начать',
      subtitle: 'Персональный путь под тебя',
      icon: Icons.route_outlined,
      color: AppColors.successGreen,
    ),
    (
      title: 'Проверим, что ты уже знаешь',
      subtitle: 'Быстрый skill-check',
      icon: Icons.check_circle_outline,
      color: AppColors.goldKey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
  }

  void _startSequence() {
    if (!mounted) return;
    final noAnim = MediaQuery.of(context).disableAnimations;

    if (noAnim) {
      setState(() {
        _visibleCards = 4;
        _showLoader = true;
      });
      _timers.add(
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) widget.onRevealComplete();
        }),
      );
      return;
    }

    for (var i = 0; i < 4; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 400 * i), () {
          if (mounted) setState(() => _visibleCards = i + 1);
        }),
      );
    }
    _timers
      ..add(
        Timer(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => _showLoader = true);
        }),
      )
      ..add(
        Timer(const Duration(milliseconds: 3000), () {
          if (mounted) widget.onRevealComplete();
        }),
      );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = widget.tokens;
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          Text(
            'Строим твой план',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: tokens.gapXxl),
          ...List.generate(_revealCards.length, (i) {
            if (i >= _visibleCards) return const SizedBox.shrink();
            final card = _revealCards[i];
            final cardWidget = Container(
              margin: EdgeInsets.only(bottom: tokens.gapMd),
              padding: EdgeInsets.all(tokens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: card.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Icon(card.icon, size: 22, color: card.color),
                  ),
                  SizedBox(width: tokens.gapMd),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.subtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            if (noAnim) return cardWidget;
            return cardWidget
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms);
          }),
          if (_showLoader) ...[
            SizedBox(height: tokens.gapLg),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            SizedBox(height: tokens.gapMd),
            Text(
              'Создаём твой план...',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 13: Completion ───────────────────────────────────────────────────────

class _CompletionStep extends ConsumerWidget {
  const _CompletionStep({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isSaving = ref.watch(profileProvider.select((s) => s.isSaving));
    final noAnim = MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 0,
            child: const MascotSlot(
              size: 130,
              tag: 'onboarding_complete',
              state: MascotState.celebrate,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 300,
            child: Text(
              'Всё готово!',
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animatedWidget(
            noAnim: noAnim,
            delay: 450,
            child: Text(
              'Профиль заполнен. Теперь Admity подберёт для тебя лучшие курсы, стипендии и прогноз шансов.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animatedWidget(
            noAnim: noAnim,
            delay: 600,
            child: FeaturedButton(
              label: 'Начать',
              isLoading: isSaving,
              onPressed: isSaving
                  ? null
                  : () {
                      final state = context
                          .findAncestorStateOfType<_OnboardingScreenState>();
                      if (state != null) {
                        unawaited(state._finish());
                      }
                    },
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}
