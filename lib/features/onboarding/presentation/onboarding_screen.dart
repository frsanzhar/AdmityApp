/// Animated onboarding flow — premium hand-crafted style.
///
/// 14 steps: role selection, mascot greeting, motivation, sound, age, subject,
/// trust, knowledge level, topic universe, daily goal + schedule,
/// notifications, 3-step plan, plan creation, and completion.
/// Each step animates in with flutter_animate (fade + slide).
/// On finish: saves profile with onboardingComplete=true → /home.
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/diagrams/onboarding/onboarding_diagrams.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Animation helper ──────────────────────────────────────────────────────────

Widget _animWrap(bool noAnim, int delayMs, Widget child) {
  if (noAnim) return child;
  return child
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: delayMs),
        duration: 400.ms,
      )
      .slideY(begin: 0.12, end: 0, duration: 400.ms);
}

// ── Main screen ───────────────────────────────────────────────────────────────

/// Premium onboarding flow for Admity.
///
/// Simultaneously introduces the app and collects the student's profile data.
/// On completion saves profile with onboardingComplete=true and navigates to /home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  static const _totalSteps = 14;

  // ── Step state ────────────────────────────────────────────────────────────

  String? _role; // step 0
  String? _motivation; // step 2
  String? _soundPreference; // step 3
  int? _age; // step 4
  final _ageCtrl = TextEditingController();
  final Set<String> _majors = {}; // step 5 — что интересно как Major
  String? _knowledgeLevel; // step 7
  int? _dailyGoalMinutes; // step 9
  String? _schedule; // step 9

  // Backward-compat fields (city step removed but kept for profile compatibility)
  String? _city;
  String? _grade;
  final _cityCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();
  final _ieltsCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  final _toeflCtrl = TextEditingController();
  final Set<String> _interests = {};

  @override
  void dispose() {
    _ageCtrl.dispose();
    _cityCtrl.dispose();
    _gpaCtrl.dispose();
    _ieltsCtrl.dispose();
    _satCtrl.dispose();
    _toeflCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) setState(() => _step++);
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    final currentProfile = ref.read(profileProvider).profile;
    final updated = currentProfile.copyWith(
      role: _role,
      motivation: _motivation,
      soundPreference: _soundPreference,
      age: _age,
      subject: _majors.isEmpty ? null : _majors.first,
      targetMajors: _majors.toList(),
      knowledgeLevel: _knowledgeLevel,
      dailyGoalMinutes: _dailyGoalMinutes,
      schedule: _schedule,
      city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : _city,
      grade: _grade,
      gpa: _gpaCtrl.text.trim().isEmpty ? null : _gpaCtrl.text.trim(),
      interests: _interests.toList(),
      onboardingComplete: true,
    );
    await ref.read(profileProvider.notifier).saveProfile(updated);
    if (mounted) context.go('/home');
  }

  // ── Determine if Далее button is enabled ──────────────────────────────────

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _role != null;
      case 2:
        return _motivation != null;
      case 3:
        return _soundPreference != null;
      case 5:
        return _majors.isNotEmpty;
      case 7:
        return _knowledgeLevel != null;
      default:
        return true;
    }
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
            _ProgressBar(step: _step, tokens: tokens, onPrev: _prev),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(context, tokens),
                ),
              ),
            ),
            _NavArea(
              step: _step,
              canAdvance: _canAdvance,
              onNext: _next,
              tokens: tokens,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppTokens tokens) {
    switch (_step) {
      case 0:
        return _RoleStep(
          tokens: tokens,
          selected: _role,
          onSelect: (r) => setState(() => _role = r),
        );
      case 1:
        return _MascotGreetingStep(tokens: tokens);
      case 2:
        return _MotivationStep(
          tokens: tokens,
          selected: _motivation,
          onSelect: (v) => setState(() => _motivation = v),
        );
      case 3:
        return _SoundStep(
          tokens: tokens,
          selected: _soundPreference,
          onSelect: (v) => setState(() => _soundPreference = v),
        );
      case 4:
        return _AgeStep(
          tokens: tokens,
          controller: _ageCtrl,
          onChanged: (v) => setState(() => _age = v),
        );
      case 5:
        return _SubjectStep(
          tokens: tokens,
          selected: _majors,
          onToggle: (v) => setState(() {
            if (!_majors.remove(v)) _majors.add(v);
          }),
        );
      case 6:
        return _UniversitiesTrustStep(tokens: tokens);
      case 7:
        return _KnowledgeLevelStep(
          tokens: tokens,
          selected: _knowledgeLevel,
          onSelect: (v) => setState(() => _knowledgeLevel = v),
        );
      case 8:
        return _TopicUniverseStep(tokens: tokens);
      case 9:
        return _GoalScheduleStep(
          tokens: tokens,
          selectedGoal: _dailyGoalMinutes,
          onGoalSelect: (v) => setState(() => _dailyGoalMinutes = v),
          selectedSchedule: _schedule,
          onScheduleSelect: (v) => setState(() => _schedule = v),
        );
      case 10:
        return _NotificationsStep(tokens: tokens);
      case 11:
        return _ThreeStepPlanStep(tokens: tokens, onCreatePlan: _next);
      case 12:
        return _PlanCreationStep(tokens: tokens, onComplete: _next);
      case 13:
        return _FinishStep(tokens: tokens, onFinish: _finish);
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

  static const _totalSegments = 12;

  @override
  Widget build(BuildContext context) {
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

// ── Nav area ──────────────────────────────────────────────────────────────────

class _NavArea extends StatelessWidget {
  const _NavArea({
    required this.step,
    required this.canAdvance,
    required this.onNext,
    required this.tokens,
  });

  final int step;
  final bool canAdvance;
  final VoidCallback onNext;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    // Steps 11+ have their own CTA buttons inside the step widget.
    if (step >= 11) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapSm,
        tokens.screenPadding,
        tokens.gapXl,
      ),
      child: PrimaryButton(
        label: 'Далее',
        onPressed: canAdvance ? onNext : null,
      ),
    );
  }
}

// ── Step 0: Role selection ────────────────────────────────────────────────────

class _RoleStep extends StatelessWidget {
  const _RoleStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const List<({String value, String label, String desc})> _roles = [
    (value: 'student', label: 'Я учусь', desc: 'Готовлюсь к поступлению'),
    (value: 'parent', label: 'Родитель', desc: 'Помогаю ребёнку поступить'),
    (value: 'teacher', label: 'Учитель', desc: 'Готовлю учеников к вузу'),
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
          _animWrap(
            noAnim,
            0,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Admity',
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            120,
            Text(
              'Поступление в университет — это большой шаг. Admity поможет пройти его уверенно.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            200,
            Text(
              'Кто ты?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapLg),
          ..._roles.asMap().entries.map((entry) {
            final i = entry.key;
            final role = entry.value;
            final isSelected = selected == role.value;
            return _animWrap(
              noAnim,
              300 + i * 80,
              Padding(
                padding: EdgeInsets.only(bottom: tokens.gapMd),
                child: GestureDetector(
                  onTap: () => onSelect(role.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.cardPadding),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.label,
                                style: textTheme.titleLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role.desc,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 1: Mascot greeting ───────────────────────────────────────────────────

class _MascotGreetingStep extends StatelessWidget {
  const _MascotGreetingStep({required this.tokens});
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
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            0,
            const MascotSlot(
              size: 140,
              flyIn: true,
              mood: MascotMood.happy,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            300,
            Text(
              'Привет! Я — Ералы,',
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            450,
            Text(
              'твой персональный наставник по поступлению. Расскажу, что нужно знать, и помогу не пропустить ни одной возможности.',
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

// ── Step 2: Motivation ────────────────────────────────────────────────────────

class _MotivationStep extends StatelessWidget {
  const _MotivationStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const List<
    ({String value, OptionDiagram3DVariant variant, String label, String desc})
  >
  _options = [
    (
      value: 'goal',
      variant: OptionDiagram3DVariant.motivation,
      label: 'Высокая цель',
      desc: 'Поступить в топ-вуз',
    ),
    (
      value: 'knowledge',
      variant: OptionDiagram3DVariant.beginner,
      label: 'Новые знания',
      desc: 'Учиться с нуля',
    ),
    (
      value: 'career',
      variant: OptionDiagram3DVariant.advanced,
      label: 'Карьера',
      desc: 'Получить хорошую работу',
    ),
    (
      value: 'interest',
      variant: OptionDiagram3DVariant.explorer,
      label: 'Интерес',
      desc: 'Просто нравится учиться',
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
          _animWrap(
            noAnim,
            0,
            Text(
              'Что тебя мотивирует?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            120,
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: tokens.gapMd,
              crossAxisSpacing: tokens.gapMd,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _options.map((opt) {
                final isSelected = selected == opt.value;
                return GestureDetector(
                  onTap: () => onSelect(opt.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: OptionDiagram3D(variant: opt.variant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.label,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt.desc,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.inkSecondary,
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

// ── Step 3: Sound preference ──────────────────────────────────────────────────

class _SoundStep extends StatelessWidget {
  const _SoundStep({
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
          _animWrap(
            noAnim,
            0,
            Text(
              'Как Ералы должен звучать?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            120,
            Row(
              children: [
                Expanded(
                  child: _SoundCard(
                    tokens: tokens,
                    value: 'melodic',
                    label: 'Мелодичный',
                    desc: 'Тёплый и дружелюбный',
                    mood: MascotMood.happy,
                    isSelected: selected == 'melodic',
                    onTap: () => onSelect('melodic'),
                  ),
                ),
                SizedBox(width: tokens.gapMd),
                Expanded(
                  child: _SoundCard(
                    tokens: tokens,
                    value: 'deep',
                    label: 'Глубокий',
                    desc: 'Уверенный и чёткий',
                    mood: MascotMood.think,
                    isSelected: selected == 'deep',
                    onTap: () => onSelect('deep'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.tokens,
    required this.value,
    required this.label,
    required this.desc,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final AppTokens tokens;
  final String value;
  final String label;
  final String desc;
  final MascotMood mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(tokens.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MascotSlot(size: 64, mood: mood),
            SizedBox(height: tokens.gapSm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 4: Age ───────────────────────────────────────────────────────────────

class _AgeStep extends StatelessWidget {
  const _AgeStep({
    required this.tokens,
    required this.controller,
    required this.onChanged,
  });

  final AppTokens tokens;
  final TextEditingController controller;
  final ValueChanged<int?> onChanged;

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
          _animWrap(
            noAnim,
            0,
            Text(
              'Сколько тебе лет?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            100,
            Text(
              'Поможет подобрать контент по возрасту.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            200,
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = int.tryParse(v.trim());
                onChanged(parsed);
              },
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '16',
                hintStyle: textTheme.headlineLarge?.copyWith(
                  color: AppColors.border,
                ),
                filled: true,
                fillColor: AppColors.surfaceTint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
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

// ── Step 5: Subject ───────────────────────────────────────────────────────────

class _SubjectStep extends StatelessWidget {
  const _SubjectStep({
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

    final majors = <_MajorOption>[
      const _MajorOption('Психология', 'Поведение и психика',
          Icons.psychology_outlined, AppColors.primary),
      const _MajorOption('Политика', 'Политология и дипломатия',
          Icons.account_balance_outlined, AppColors.successGreen),
      const _MajorOption('Экономика', 'Финансы и бизнес',
          Icons.trending_up_rounded, AppColors.goldKey),
      const _MajorOption('Химия', 'Реакции и вещества',
          Icons.science_outlined, AppColors.errorRed),
      const _MajorOption('Биология', 'Жизнь и медицина',
          Icons.biotech_outlined, AppColors.successGreen),
      const _MajorOption('Физика', 'Механика и кванты',
          Icons.bolt_outlined, AppColors.primary),
      const _MajorOption('Математика', 'Алгебра и анализ',
          Icons.calculate_outlined, AppColors.goldKey),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            0,
            Text(
              'Какие предметы интересны как Major?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            60,
            Text(
              'Можно выбрать несколько',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          for (var i = 0; i < majors.length; i++) ...[
            _animWrap(
              noAnim,
              120 + i * 50,
              _SubjectCard(
                tokens: tokens,
                value: majors[i].name,
                label: majors[i].name,
                desc: majors[i].desc,
                accentColor: majors[i].color,
                icon: majors[i].icon,
                isSelected: selected.contains(majors[i].name),
                onTap: () => onToggle(majors[i].name),
              ),
            ),
            SizedBox(height: tokens.gapMd),
          ],
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

/// A selectable Major option shown on the subject step.
class _MajorOption {
  const _MajorOption(this.name, this.desc, this.icon, this.color);
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.tokens,
    required this.value,
    required this.label,
    required this.desc,
    required this.accentColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final AppTokens tokens;
  final String value;
  final String label;
  final String desc;
  final Color accentColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(tokens.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
              ),
              child: Icon(icon, size: 24, color: accentColor),
            ),
            SizedBox(width: tokens.gapMd),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.titleLarge?.copyWith(
                      color: isSelected ? accentColor : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Step 6: Universities trust ────────────────────────────────────────────────

class _UniversitiesTrustStep extends StatelessWidget {
  const _UniversitiesTrustStep({required this.tokens});
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
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            0,
            Text(
              'Построено с экспертами ведущих вузов',
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            120,
            Text(
              'Контент разработан при участии методистов университетов Казахстана и международных партнёров.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            240,
            const SizedBox(
              width: 200,
              height: 160,
              child: UniversitiesDiagram(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 7: Knowledge level ───────────────────────────────────────────────────

class _KnowledgeLevelStep extends StatelessWidget {
  const _KnowledgeLevelStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const List<
    ({String value, OptionDiagram3DVariant variant, String label, String desc})
  >
  _levels = [
    (
      value: 'beginner',
      variant: OptionDiagram3DVariant.beginner,
      label: 'Новичок',
      desc: 'Только начинаю разбираться',
    ),
    (
      value: 'middle',
      variant: OptionDiagram3DVariant.motivation,
      label: 'Средний уровень',
      desc: 'Знаю основы, хочу углубиться',
    ),
    (
      value: 'advanced',
      variant: OptionDiagram3DVariant.advanced,
      label: 'Продвинутый',
      desc: 'Уверенно решаю задачи',
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
          _animWrap(
            noAnim,
            0,
            Text(
              'Как ты оцениваешь свои знания?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          ..._levels.asMap().entries.map((entry) {
            final i = entry.key;
            final level = entry.value;
            final isSelected = selected == level.value;
            return _animWrap(
              noAnim,
              120 + i * 80,
              Padding(
                padding: EdgeInsets.only(bottom: tokens.gapMd),
                child: GestureDetector(
                  onTap: () => onSelect(level.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.cardPadding),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: OptionDiagram3D(variant: level.variant),
                        ),
                        SizedBox(width: tokens.gapMd),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: textTheme.titleLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                level.desc,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 13,
                              color: AppColors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 8: Topic universe ────────────────────────────────────────────────────

class _TopicUniverseStep extends StatefulWidget {
  const _TopicUniverseStep({required this.tokens});
  final AppTokens tokens;

  @override
  State<_TopicUniverseStep> createState() => _TopicUniverseStepState();
}

class _TopicUniverseStepState extends State<_TopicUniverseStep> {
  bool _expanded = false;
  bool _showBranch = false;
  Timer? _expandTimer;
  Timer? _branchTimer;

  @override
  void initState() {
    super.initState();
    _expandTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _expanded = true);
    });
    _branchTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showBranch = true);
    });
  }

  @override
  void dispose() {
    _expandTimer?.cancel();
    _branchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;
    final tokens = widget.tokens;

    // In reduced motion mode, show everything immediately.
    final effectiveExpanded = noAnim || _expanded;
    final effectiveShowBranch = noAnim || _showBranch;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            0,
            Text(
              'Всё, что нужно — уже здесь',
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            80,
            // TopicMapDiagram uses CustomPaint(size: Size.infinite) and
            // needs a bounded box when placed inside a SingleChildScrollView
            // column; without bounds the RenderCustomPaint gets infinite
            // height → layout error → blank screen (CLAUDE.md gotcha §2).
            SizedBox(
              height: 220,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: TopicMapDiagram(
                  key: ValueKey(effectiveExpanded),
                  expanded: effectiveExpanded,
                ),
              ),
            ),
          ),
          if (effectiveShowBranch) ...[
            SizedBox(height: tokens.gapLg),
            const MascotSlot(
              size: 80,
              mood: MascotMood.happy,
            ),
            SizedBox(height: tokens.gapSm),
            Text(
              'Я знаю, с чего начать',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: tokens.gapMd),
            // Needs bounded height (same gotcha as TopicMapDiagram above).
            const SizedBox(
              height: 180,
              child: KnowledgeBranchDiagram(),
            ),
          ],
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 9: Daily goal + schedule ─────────────────────────────────────────────

class _GoalScheduleStep extends StatelessWidget {
  const _GoalScheduleStep({
    required this.tokens,
    required this.selectedGoal,
    required this.onGoalSelect,
    required this.selectedSchedule,
    required this.onScheduleSelect,
  });

  final AppTokens tokens;
  final int? selectedGoal;
  final ValueChanged<int> onGoalSelect;
  final String? selectedSchedule;
  final ValueChanged<String> onScheduleSelect;

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

  static const List<
    ({String value, String emoji, String label, String subtitle})
  >
  _schedules = [
    (value: 'Утро', emoji: '🌅', label: 'Утро', subtitle: 'До начала дня'),
    (value: 'День', emoji: '☀', label: 'День', subtitle: 'В свободное время'),
    (value: 'Вечер', emoji: '🌙', label: 'Вечер', subtitle: 'После учёбы'),
    (
      value: 'Когда получится',
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
          _animWrap(
            noAnim,
            0,
            Text(
              'Сколько времени в день?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapLg),
          _animWrap(
            noAnim,
            80,
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _goals.map((goal) {
                final isSelected = selectedGoal == goal.minutes;
                return GestureDetector(
                  onTap: () => onGoalSelect(goal.minutes),
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
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            160,
            Container(
              height: 1,
              color: AppColors.border,
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            200,
            Text(
              'Когда удобнее?',
              style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapLg),
          _animWrap(
            noAnim,
            240,
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _schedules.map((s) {
                final isSelected = selectedSchedule == s.value;
                return GestureDetector(
                  onTap: () => onScheduleSelect(s.value),
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
                        Text(
                          s.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge?.copyWith(
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

// ── Step 10: Notifications ────────────────────────────────────────────────────

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final noAnim = MediaQuery.of(context).disableAnimations;
    final state = context.findAncestorStateOfType<_OnboardingScreenState>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            0,
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(tokens.radiusXl),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            120,
            Text(
              'Напоминания',
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            200,
            Text(
              'Хочешь, чтобы Admity напоминал о занятиях?',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            300,
            // TODO(notifications): wire up actual permission request
            PrimaryButton(
              label: 'Включить',
              onPressed: () => state?._next(),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            380,
            TextButton(
              onPressed: () => state?._next(),
              child: Text(
                'Пропустить',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
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

// ── Step 11: Three-step plan ──────────────────────────────────────────────────

class _ThreeStepPlanStep extends StatelessWidget {
  const _ThreeStepPlanStep({
    required this.tokens,
    required this.onCreatePlan,
  });

  final AppTokens tokens;
  final VoidCallback onCreatePlan;

  static const List<({PlanStepVariant variant, String title, String desc})>
  _planSteps = [
    (
      variant: PlanStepVariant.start,
      title: 'Изучи основы',
      desc: 'Разберём базу по твоему предмету',
    ),
    (
      variant: PlanStepVariant.improve,
      title: 'Практикуй',
      desc: 'Задачи, тесты, разборы ошибок',
    ),
    (
      variant: PlanStepVariant.test,
      title: 'Проверь себя',
      desc: 'Финальный skill-check и анализ результатов',
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
          _animWrap(
            noAnim,
            0,
            Text(
              'Твой план на три шага',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          ..._planSteps.asMap().entries.map((entry) {
            final i = entry.key;
            final planStep = entry.value;
            return _animWrap(
              noAnim,
              120 + i * 80,
              Padding(
                padding: EdgeInsets.only(bottom: tokens.gapMd),
                child: Container(
                  width: double.infinity,
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
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: PlanStepDiagram(variant: planStep.variant),
                      ),
                      SizedBox(width: tokens.gapMd),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planStep.title,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              planStep.desc,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            400,
            FeaturedButton(
              label: 'Создать мой план',
              onPressed: onCreatePlan,
            ),
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

// ── Step 12: Plan creation (auto-advancing) ───────────────────────────────────

class _PlanCreationStep extends StatefulWidget {
  const _PlanCreationStep({
    required this.tokens,
    required this.onComplete,
  });

  final AppTokens tokens;
  final VoidCallback onComplete;

  @override
  State<_PlanCreationStep> createState() => _PlanCreationStepState();
}

class _PlanCreationStepState extends State<_PlanCreationStep> {
  int _visibleCards = 0;
  bool _showLoader = false;
  final List<Timer> _timers = [];

  static const List<({String title, IconData icon, Color color})> _cards = [
    (
      title: 'Анализируем твой профиль',
      icon: Icons.person_search_outlined,
      color: AppColors.primary,
    ),
    (
      title: 'Подбираем курсы',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.accentLime,
    ),
    (
      title: 'Строим путь',
      icon: Icons.route_outlined,
      color: AppColors.successGreen,
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
        _visibleCards = 3;
        _showLoader = true;
      });
      _timers.add(
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) widget.onComplete();
        }),
      );
      return;
    }

    for (var i = 0; i < 3; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 500 * i), () {
          if (mounted) setState(() => _visibleCards = i + 1);
        }),
      );
    }
    _timers
      ..add(
        Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showLoader = true);
        }),
      )
      ..add(
        Timer(const Duration(milliseconds: 3000), () {
          if (mounted) widget.onComplete();
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
          SizedBox(height: tokens.gapXxl),
          Text(
            'Создаём твой план…',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: tokens.gapXxl),
          ...List.generate(_cards.length, (i) {
            if (i >= _visibleCards) return const SizedBox.shrink();
            final card = _cards[i];
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
                    child: Text(
                      card.title,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 20,
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: tokens.gapMd),
            Text(
              'Почти готово…',
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

// ── Step 13: Finish ───────────────────────────────────────────────────────────

class _FinishStep extends ConsumerWidget {
  const _FinishStep({
    required this.tokens,
    required this.onFinish,
  });

  final AppTokens tokens;
  final Future<void> Function() onFinish;

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
          _animWrap(
            noAnim,
            0,
            const MascotSlot(
              size: 140,
              flyIn: true,
              mood: MascotMood.celebrate,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            300,
            Text(
              'Всё готово!',
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            450,
            Text(
              'Твой персональный план создан. Начинаем?',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            560,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Чтобы сохранить прогресс в облаке, войди через:',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
                SizedBox(height: tokens.gapMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AuthGhostButton(
                      label: 'Google',
                      onTap: () {
                        // TODO(auth): wire Google sign-in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Скоро / Coming soon')),
                        );
                      },
                    ),
                    SizedBox(width: tokens.gapSm),
                    _AuthGhostButton(
                      label: 'Apple',
                      onTap: () {
                        // TODO(auth): wire Apple sign-in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Скоро / Coming soon')),
                        );
                      },
                    ),
                    SizedBox(width: tokens.gapSm),
                    _AuthGhostButton(
                      label: 'Email',
                      onTap: () {
                        // TODO(auth): wire email sign-in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Скоро / Coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapXl),
          _animWrap(
            noAnim,
            650,
            FeaturedButton(
              label: 'Начать',
              isLoading: isSaving,
              onPressed: isSaving ? null : () => unawaited(onFinish()),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            730,
            TextButton(
              onPressed: isSaving ? null : () => unawaited(onFinish()),
              child: Text(
                'Продолжить без входа',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
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

class _AuthGhostButton extends StatelessWidget {
  const _AuthGhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
        ),
      ),
    );
  }
}
