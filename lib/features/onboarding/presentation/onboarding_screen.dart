/// Animated onboarding flow — premium hand-crafted style.
///
/// 13 steps: role selection, mascot greeting, motivation (3 opts), age, subject,
/// universities trust, confidence, academic stats, topic universe,
/// daily goal + schedule, notifications, 3-step plan, plan creation, and completion.
/// Each step animates in with flutter_animate (fade + slide).
/// On finish: saves profile with onboardingComplete=true → /home.
library;

import 'dart:async';

import 'package:admity/core/config/app_config.dart';
import 'package:admity/core/notifications/notifications_service.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

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

// ── Study plan generator ──────────────────────────────────────────────────────

/// Generates a 4-6 step study plan purely from profile data.
///
/// No network calls — pure Dart so the plan is always available offline.
List<String> _generateStudyPlan({
  required List<String> targetMajors,
  required String? confidence,
  required String? schedule,
  required String? motivation,
}) {
  final major = targetMajors.isNotEmpty ? targetMajors.first : 'выбранному направлению';
  final timeLabel = switch (schedule) {
    'Утро' => 'утром',
    'День' => 'днём',
    'Вечер' => 'вечером',
    _ => 'в удобное время',
  };

  // Starter plan — order varies by confidence level.
  final isEarlyStage = confidence == 'Только начинаю' || confidence == 'Ещё не уверен';

  final steps = <String>[
    if (isEarlyStage)
      'Пройди профориентационный тест, чтобы подтвердить интерес к $major'
    else
      'Убедись, что профиль — ЕНТ, ГПА, оценки — актуален и точен',
    'Изучи вступительные требования и проходные баллы по направлению $major',
    'Составь список целевых вузов (Казахстан и/или за рубежом) с дедлайнами',
    'Выдели $timeLabel ежедневное время для подготовки и придерживайся расписания',
    'Практикуй тестовые задания ЕНТ / международные экзамены по выбранным предметам',
    if (motivation == 'Поступить в вуз за рубежом')
      'Подготовь документы для международных заявок: эссе, рекомендации, языковые сертификаты'
    else
      'Собери пакет документов: аттестат, транскрипт, рекомендательные письма',
  ];

  return steps;
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

  // Total visible steps: 0..12 (the finish step at 12 calls _finish on button tap).
  // Steps: 0=role, 1=mascot, 2=motivation, 3=age, 4=subject, 5=trust,
  //        6=confidence, 7=stats, 8=topic-universe, 9=goal+schedule,
  //        10=notifications, 11=plan-preview, 12=plan-creation, 13=finish.
  static const _totalSteps = 14;

  // ── Step state ────────────────────────────────────────────────────────────

  String? _role; // step 0
  String? _motivation; // step 2
  int? _age; // step 3
  final _ageCtrl = TextEditingController();
  final Set<String> _majors = {}; // step 4
  String? _confidence; // step 6
  // Step 7 — academic stats (all optional / skippable).
  final _gpaCtrl = TextEditingController();
  final _ieltsCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  int? _dailyGoalMinutes; // step 9
  String? _schedule; // step 9

  // Backward-compat note: study plan is generated in _finish and saved to profile.

  // Backward-compat fields kept for profile compatibility.
  String? _city;
  String? _grade;
  final _cityCtrl = TextEditingController();
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
    // Generate study plan from collected profile data before saving.
    final plan = _generateStudyPlan(
      targetMajors: _majors.toList(),
      confidence: _confidence,
      schedule: _schedule,
      motivation: _motivation,
    );

    final currentProfile = ref.read(profileProvider).profile;
    final updated = currentProfile.copyWith(
      role: _role,
      motivation: _motivation,
      age: _age,
      subject: _majors.isEmpty ? null : _majors.first,
      targetMajors: _majors.toList(),
      confidence: _confidence,
      gpa: _gpaCtrl.text.trim().isEmpty ? null : _gpaCtrl.text.trim(),
      ieltsScore: _ieltsCtrl.text.trim().isEmpty ? null : _ieltsCtrl.text.trim(),
      satScore: _satCtrl.text.trim().isEmpty ? null : _satCtrl.text.trim(),
      dailyGoalMinutes: _dailyGoalMinutes,
      schedule: _schedule,
      city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : _city,
      grade: _grade,
      interests: _interests.toList(),
      studyPlan: plan,
      onboardingComplete: true,
    );
    await ref.read(profileProvider.notifier).saveProfile(updated);

    // Ask for notification permission and schedule a real daily study reminder.
    // Fire-and-forget — navigation must not wait on the OS permission dialog.
    unawaited(_scheduleStudyReminder(_schedule, _dailyGoalMinutes));

    if (mounted) {
      bool hasSession = false;
      if (AppConfig.hasSupabase) {
        try {
          hasSession = Supabase.instance.client.auth.currentSession != null;
        } catch (_) {}
      }
      
      final hasAuth = updated.authProvider != null || hasSession;
      if (hasAuth) {
        context.go('/home');
      } else {
        context.go('/auth');
      }
    }
  }

  /// Requests notification permission, then schedules a daily reminder at the
  /// hour matching the student's chosen [schedule] (morning / day / evening).
  Future<void> _scheduleStudyReminder(
    String? schedule,
    int? dailyGoalMinutes,
  ) async {
    final granted = await NotificationsService.requestPermission();
    if (!granted) return;
    final hour = switch (schedule) {
      'Утро' => 9,
      'День' => 14,
      'Вечер' => 19,
      _ => 18,
    };
    final minutes = dailyGoalMinutes ?? 20;
    await NotificationsService.scheduleDailyReminder(
      id: 1001,
      hour: hour,
      minute: 0,
      title: 'Время учиться с Admity 🎓',
      body: 'Удели $minutes мин подготовке к поступлению — ты на верном пути!',
    );
  }

  // ── Determine if Далее button is enabled ──────────────────────────────────

  /// Restricts advancement until a selection is made on critical steps.
  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _role != null;
      case 2:
        return _motivation != null;
      case 3:
        return _age != null;
      case 4:
        return _majors.isNotEmpty;
      case 6:
        return _confidence != null;
      case 9:
        return _dailyGoalMinutes != null && _schedule != null;
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
        return _AgeStep(
          tokens: tokens,
          controller: _ageCtrl,
          onChanged: (v) => setState(() => _age = v),
        );
      case 4:
        return _SubjectStep(
          tokens: tokens,
          selected: _majors,
          onToggle: (v) => setState(() {
            if (!_majors.remove(v)) _majors.add(v);
          }),
        );
      case 5:
        return _UniversitiesTrustStep(tokens: tokens);
      case 6:
        return _ConfidenceStep(
          tokens: tokens,
          selected: _confidence,
          onSelect: (v) => setState(() => _confidence = v),
        );
      case 7:
        return _StatsStep(
          tokens: tokens,
          gpaCtrl: _gpaCtrl,
          ieltsCtrl: _ieltsCtrl,
          satCtrl: _satCtrl,
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

  // Segments shown = total steps minus the last two (plan-creation + finish
  // which have no progress bar).
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

// ── Step 2: Motivation (3 options) ────────────────────────────────────────────

class _MotivationStep extends StatelessWidget {
  const _MotivationStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  /// Exactly 3 motivation options as per spec.
  static const List<({String value, IconData icon, Color color, String label, String desc})>
  _options = [
    (
      value: 'Поступить в топ-вуз Казахстана',
      icon: Icons.account_balance_rounded,
      color: AppColors.primary,
      label: 'Поступить в топ-вуз Казахстана',
      desc: 'НУ, КБТУ, КазНУ и другие',
    ),
    (
      value: 'Поступить в вуз за рубежом',
      icon: Icons.flight_takeoff_rounded,
      color: AppColors.successGreen,
      label: 'Поступить в вуз за рубежом',
      desc: 'США, Европа, Азия и другие страны',
    ),
    (
      value: 'Профориентация',
      icon: Icons.explore_rounded,
      color: AppColors.goldKey,
      label: 'Профориентация',
      desc: 'Ещё выбираю направление',
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
              'Какова твоя цель?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            80,
            Text(
              'Это поможет подобрать правильный путь',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          ..._options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isSelected = selected == opt.value;
            return _animWrap(
              noAnim,
              120 + i * 80,
              Padding(
                padding: EdgeInsets.only(bottom: tokens.gapMd),
                child: GestureDetector(
                  onTap: () => onSelect(opt.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.cardPadding),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? opt.color.withValues(alpha: 0.08)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected ? opt.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: opt.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(tokens.radiusMd),
                          ),
                          child: Icon(opt.icon, size: 24, color: opt.color),
                        ),
                        SizedBox(width: tokens.gapMd),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: textTheme.titleMedium?.copyWith(
                                  color: isSelected ? opt.color : AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt.desc,
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
                            decoration: BoxDecoration(
                              color: opt.color,
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

// ── Step 3: Age ───────────────────────────────────────────────────────────────

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

// ── Step 4: Subject / Majors ──────────────────────────────────────────────────

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

// ── Step 5: Universities trust ────────────────────────────────────────────────

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

// ── Step 6: Confidence ────────────────────────────────────────────────────────

class _ConfidenceStep extends StatelessWidget {
  const _ConfidenceStep({
    required this.tokens,
    required this.selected,
    required this.onSelect,
  });

  final AppTokens tokens;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const List<({String value, IconData icon, Color color, String label, String desc})>
  _levels = [
    (
      value: 'Уверен на 100%',
      icon: Icons.emoji_events_rounded,
      color: AppColors.goldKey,
      label: 'Уверен на 100%',
      desc: 'Знаю, что поступлю',
    ),
    (
      value: 'Скорее да',
      icon: Icons.thumb_up_rounded,
      color: AppColors.successGreen,
      label: 'Скорее да',
      desc: 'Хороший шанс есть',
    ),
    (
      value: 'Ещё не уверен',
      icon: Icons.help_outline_rounded,
      color: AppColors.primary,
      label: 'Ещё не уверен',
      desc: 'Нужно больше подготовки',
    ),
    (
      value: 'Только начинаю',
      icon: Icons.directions_walk_rounded,
      color: AppColors.errorRed,
      label: 'Только начинаю',
      desc: 'Ещё не разобрался с целями',
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
              'Насколько ты уверен, что поступишь?',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            80,
            Text(
              'Честный ответ поможет правильно составить план',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
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
                          ? level.color.withValues(alpha: 0.08)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(
                        color: isSelected ? level.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: level.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(tokens.radiusMd),
                          ),
                          child: Icon(level.icon, size: 24, color: level.color),
                        ),
                        SizedBox(width: tokens.gapMd),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: textTheme.titleMedium?.copyWith(
                                  color: isSelected ? level.color : AppColors.ink,
                                  fontWeight: FontWeight.w600,
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
                            decoration: BoxDecoration(
                              color: level.color,
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

// ── Step 7: Academic stats ────────────────────────────────────────────────────

/// Collects GPA, IELTS, and SAT in one combined step.
///
/// All fields are optional — a "Пропустить" option is provided via the
/// standard Далее button (which is always enabled for this step).
class _StatsStep extends StatelessWidget {
  const _StatsStep({
    required this.tokens,
    required this.gpaCtrl,
    required this.ieltsCtrl,
    required this.satCtrl,
  });

  final AppTokens tokens;
  final TextEditingController gpaCtrl;
  final TextEditingController ieltsCtrl;
  final TextEditingController satCtrl;

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
              'Твои академические показатели',
              style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          _animWrap(
            noAnim,
            80,
            Text(
              'Необязательно — можно пропустить. Это нужно для честной оценки шансов.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          _animWrap(
            noAnim,
            160,
            _StatsField(
              tokens: tokens,
              controller: gpaCtrl,
              label: 'ГПА / Средний балл',
              hint: 'Например: 4.8',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            240,
            _StatsField(
              tokens: tokens,
              controller: ieltsCtrl,
              label: 'IELTS (если есть)',
              hint: 'Например: 7.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          SizedBox(height: tokens.gapMd),
          _animWrap(
            noAnim,
            320,
            _StatsField(
              tokens: tokens,
              controller: satCtrl,
              label: 'SAT (если есть)',
              hint: 'Например: 1400',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

/// A single labeled text field used in [_StatsStep].
class _StatsField extends StatelessWidget {
  const _StatsField({
    required this.tokens,
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
  });

  final AppTokens tokens;
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.border),
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
      ],
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
      title: 'Подбираем вузы и направления',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.accentLime,
    ),
    (
      title: 'Строим персональный путь',
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
            650,
            FeaturedButton(
              label: 'Начать',
              isLoading: isSaving,
              onPressed: isSaving ? null : () => unawaited(onFinish()),
            ),
          ),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// (Removed _AuthGhostButton — sign-in now happens up front on the /auth screen,
// not at the end of onboarding.)
