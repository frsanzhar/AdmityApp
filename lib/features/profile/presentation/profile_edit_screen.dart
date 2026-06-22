/// Full-screen "Мои данные" editor — opened from the Profile pencil icon.
///
/// Design rules (DESIGN_SYSTEM.md §7.7 / §8):
///   - SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)
///   - No CrossAxisAlignment.stretch inside scroll view
///   - Colors only AppColors; font Onest via theme
///   - PrimaryButton for Save (standard action)
///   - One accent per screen: AppColors.primary (cobalt)
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen editor for all student self-data.
///
/// Opened by the pencil icon on ProfileScreen (→ context.push('/profile/edit')).
/// On Save: calls [ProfileNotifier.saveProfile] then pops.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // Controllers — initialised in initState once the profile is available.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _gpaCtrl;
  late final TextEditingController _interestsCtrl;
  late final TextEditingController _majorsCtrl;
  late final TextEditingController _ieltsCtrl;
  late final TextEditingController _satCtrl;
  late final TextEditingController _toeflCtrl;
  late final TextEditingController _languagesCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider).profile;
    _nameCtrl = TextEditingController(text: p.name ?? '');
    _gradeCtrl = TextEditingController(text: p.grade ?? '');
    _cityCtrl = TextEditingController(text: p.city ?? '');
    _gpaCtrl = TextEditingController(text: p.gpa ?? p.gpaBand ?? '');
    _interestsCtrl = TextEditingController(text: p.interests.join(', '));
    _majorsCtrl = TextEditingController(text: p.targetMajors.join(', '));
    _ieltsCtrl = TextEditingController(text: p.ieltsScore ?? '');
    _satCtrl = TextEditingController(text: p.satScore ?? '');
    _toeflCtrl = TextEditingController(text: p.toeflScore ?? '');
    _languagesCtrl = TextEditingController(text: p.languages.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    _cityCtrl.dispose();
    _gpaCtrl.dispose();
    _interestsCtrl.dispose();
    _majorsCtrl.dispose();
    _ieltsCtrl.dispose();
    _satCtrl.dispose();
    _toeflCtrl.dispose();
    _languagesCtrl.dispose();
    super.dispose();
  }

  List<String> _split(String v) =>
      v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String? _nonEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _save() async {
    final current = ref.read(profileProvider).profile;
    final updated = current.copyWith(
      name: _nonEmpty(_nameCtrl.text),
      grade: _nonEmpty(_gradeCtrl.text),
      city: _nonEmpty(_cityCtrl.text),
      gpa: _nonEmpty(_gpaCtrl.text),
      interests: _split(_interestsCtrl.text),
      targetMajors: _split(_majorsCtrl.text),
      ieltsScore: _nonEmpty(_ieltsCtrl.text),
      satScore: _nonEmpty(_satCtrl.text),
      toeflScore: _nonEmpty(_toeflCtrl.text),
      languages: _split(_languagesCtrl.text),
    );
    await ref.read(profileProvider.notifier).saveProfile(updated);
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Данные сохранены'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final isSaving = ref.watch(profileProvider.select((s) => s.isSaving));

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Мои данные',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.screenPadding,
            vertical: tokens.gapXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personal info ──────────────────────────────────────────
              _SectionLabel(
                label: 'Личные данные',
                tokens: tokens,
              ),
              SizedBox(height: tokens.gapMd),
              AppCard(
                animateIn: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'Имя',
                      hint: 'Как тебя зовут?',
                      controller: _nameCtrl,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'Класс',
                      hint: '11 класс',
                      controller: _gradeCtrl,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'Город',
                      hint: 'Алматы, Астана...',
                      controller: _cityCtrl,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'Средний балл / ГПА',
                      hint: '4.8',
                      controller: _gpaCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'Языки (через запятую)',
                      hint: 'KZ, RU, EN',
                      controller: _languagesCtrl,
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.gapXl),

              // ── Academic interests ─────────────────────────────────────
              _SectionLabel(label: 'Направления и интересы', tokens: tokens),
              SizedBox(height: tokens.gapMd),
              AppCard(
                animateIn: true,
                animateDelay: const Duration(milliseconds: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'Направления учёбы (через запятую)',
                      hint: 'IT, Медицина, Финансы...',
                      controller: _majorsCtrl,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'Интересы и хобби (через запятую)',
                      hint: 'Математика, Дизайн, Музыка...',
                      controller: _interestsCtrl,
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.gapXl),

              // ── Exam scores ────────────────────────────────────────────
              _SectionLabel(label: 'Результаты экзаменов', tokens: tokens),
              SizedBox(height: tokens.gapMd),
              AppCard(
                animateIn: true,
                animateDelay: const Duration(milliseconds: 160),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'IELTS балл',
                      hint: '7.0',
                      controller: _ieltsCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'SAT балл',
                      hint: '1400',
                      controller: _satCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _Field(
                      label: 'TOEFL балл',
                      hint: '100',
                      controller: _toeflCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.gapXxl),

              // ── Save button ────────────────────────────────────────────
              PrimaryButton(
                label: 'Сохранить',
                onPressed: isSaving ? null : _save,
                isLoading: isSaving,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 300),
              ),
              SizedBox(height: tokens.gapXxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.tokens});
  final String label;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
    );
  }
}

// ── Text field component ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
            filled: true,
            fillColor: AppColors.surfaceTint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
