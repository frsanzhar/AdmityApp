/// Animated onboarding flow — Brilliant/Duolingo-style.
///
/// 10 steps: 5 feature intro slides + 4 data-collection steps + completion.
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
  static const _totalSteps = 10;

  // Data collection state
  String? _grade;
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
    final updated = currentProfile.copyWith(
      grade: _grade,
      gpa: _gpaCtrl.text.trim().isEmpty ? null : _gpaCtrl.text.trim(),
      ieltsScore: _hasIelts && _ieltsCtrl.text.trim().isNotEmpty
          ? _ieltsCtrl.text.trim()
          : null,
      satScore: _hasSat && _satCtrl.text.trim().isNotEmpty
          ? _satCtrl.text.trim()
          : null,
      toeflScore: _hasToefl && _toeflCtrl.text.trim().isNotEmpty
          ? _toeflCtrl.text.trim()
          : null,
      interests: _interests.toList(),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            _ProgressBar(step: _step, total: _totalSteps, tokens: tokens),

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
            _NavButtons(
              step: _step,
              total: _totalSteps,
              onNext: _next,
              onPrev: _prev,
              onFinish: _finish,
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
          title: 'Ералы — AI-ментор',
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
        return _GradeStep(
          tokens: tokens,
          selected: _grade,
          onSelect: (g) => setState(() => _grade = g),
        );
      case 6:
        return _GpaStep(tokens: tokens, controller: _gpaCtrl);
      case 7:
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
    required this.total,
    required this.tokens,
  });

  final int step;
  final int total;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapMd,
        tokens.screenPadding,
        tokens.gapSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapXs),
          Text(
            '${step + 1} / $total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Nav buttons ───────────────────────────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.step,
    required this.total,
    required this.onNext,
    required this.onPrev,
    required this.onFinish,
    required this.tokens,
  });

  final int step;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onFinish;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapMd,
        tokens.screenPadding,
        tokens.gapXl,
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            SizedBox(
              height: 52,
              width: 52,
              child: ElevatedButton(
                onPressed: onPrev,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceTint,
                  foregroundColor: AppColors.ink,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
            SizedBox(width: tokens.gapMd),
          ],
          Expanded(
            child: isLast
                ? const SizedBox.shrink()
                : PrimaryButton(label: 'Далее', onPressed: onNext),
          ),
        ],
      ),
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          const MascotSlot(tag: 'onboarding_welcome')
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
          SizedBox(height: tokens.gapXl),
          Text(
                'Добро пожаловать в Admity',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: tokens.gapMd),
          Text(
                'Честный прогноз поступления, AI-ментор Ералы, курсы и стипендии — всё в одном приложении.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: tokens.gapXxl),
          const _FeaturePill(
            icon: Icons.analytics_outlined,
            label: 'Честные шансы',
          ).animate().fadeIn(delay: 500.ms),
          SizedBox(height: tokens.gapSm),
          const _FeaturePill(
            icon: Icons.school_outlined,
            label: 'Геймифицированные курсы',
          ).animate().fadeIn(delay: 600.ms),
          SizedBox(height: tokens.gapSm),
          const _FeaturePill(
            icon: Icons.psychology_outlined,
            label: 'AI-ментор Ералы',
          ).animate().fadeIn(delay: 700.ms),
          SizedBox(height: tokens.gapSm),
          const _FeaturePill(
            icon: Icons.star_outline_rounded,
            label: 'Стипендии и возможности',
          ).animate().fadeIn(delay: 800.ms),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXxl),
          if (useMascot)
            const MascotSlot(size: 110, tag: 'onboarding_feature')
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn()
          else if (useTopicDiagram)
            const TopicDiagramSlot(size: 110)
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn()
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(tokens.radiusXl),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
          SizedBox(height: tokens.gapXxl),
          Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
              )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          SizedBox(height: tokens.gapMd),
          Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 5: Grade ─────────────────────────────────────────────────────────────

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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          Text(
            'Твой класс / ступень',
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapSm),
          Text(
                'Это поможет нам подобрать подходящие курсы и контент.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapXxl),
          Wrap(
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
                      color: isSelected ? AppColors.primary : AppColors.border,
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
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 6: GPA ───────────────────────────────────────────────────────────────

class _GpaStep extends StatelessWidget {
  const _GpaStep({required this.tokens, required this.controller});
  final AppTokens tokens;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          Text(
            'Средний балл / ГПА',
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapSm),
          Text(
                'Введи свой средний балл (например: 4.8 или 90). Можешь пропустить.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapXxl),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 7: Exams ─────────────────────────────────────────────────────────────

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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          Text(
            'Стандартизированные экзамены',
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapSm),
          Text(
            'Отметь экзамены, которые ты сдавал(а), и введи баллы.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          SizedBox(height: tokens.gapXxl),
          _ExamToggleRow(
            label: 'IELTS',
            active: hasIelts,
            onToggle: onToggleIelts,
            controller: ieltsCtrl,
            hint: 'Например: 7.0',
            tokens: tokens,
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: tokens.gapMd),
          _ExamToggleRow(
            label: 'SAT',
            active: hasSat,
            onToggle: onToggleSat,
            controller: satCtrl,
            hint: 'Например: 1400',
            tokens: tokens,
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: tokens.gapMd),
          _ExamToggleRow(
            label: 'TOEFL',
            active: hasToefl,
            onToggle: onToggleToefl,
            controller: toeflCtrl,
            hint: 'Например: 100',
            tokens: tokens,
          ).animate().fadeIn(delay: 400.ms),
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.gapXxl),
          Text(
            'Интересы и увлечения',
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapSm),
          Text(
            'Выбери всё, что тебе интересно. Это поможет подобрать контент.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          SizedBox(height: tokens.gapXxl),
          Wrap(
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
                      color: isSelected ? AppColors.primary : AppColors.border,
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
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}

// ── Step 9: Completion ────────────────────────────────────────────────────────

class _CompletionStep extends ConsumerWidget {
  const _CompletionStep({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isSaving = ref.watch(profileProvider.select((s) => s.isSaving));

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          const MascotSlot(
                size: 130,
                tag: 'onboarding_complete',
                state: MascotState.celebrate,
              )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
          SizedBox(height: tokens.gapXxl),
          Text(
                'Всё готово!',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: tokens.gapMd),
          Text(
                'Профиль заполнен. Теперь Admity подберёт для тебя лучшие курсы, стипендии и прогноз шансов.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 450.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: tokens.gapXxl),
          FeaturedButton(
            label: 'Начать',
            isLoading: isSaving,
            onPressed: isSaving
                ? null
                : () {
                    // Finish is triggered from parent via _NavButtons onFinish,
                    // but on the last step _NavButtons shows no next button.
                    // We need to call finish from here via the state.
                    // Since _CompletionStep is inside _OnboardingScreenState,
                    // we use a callback stored via InheritedWidget approach —
                    // simpler: use context to find the state.
                    final state = context
                        .findAncestorStateOfType<_OnboardingScreenState>();
                    if (state != null) {
                      unawaited(state._finish());
                    }
                  },
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}
