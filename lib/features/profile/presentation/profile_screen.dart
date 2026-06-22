/// Profile screen — §7.7 DESIGN_SYSTEM.md (revamped).
///
/// Sections:
///   1. Мои данные — view/edit toggle via pencil icon in header.
///   2. Профориентация — tappable card navigating to /career-test.
///   3. Пакет документов — seeded default KZ pack, checkbox-toggle items.
///
/// Anti-slop rules (CLAUDE.md):
///   - AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min)
///   - NEVER CrossAxisAlignment.stretch inside a scroll view
///   - Colors only AppColors, font only Onest via theme
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSeedPackage());
  }

  Future<void> _maybeSeedPackage() async {
    if (_seeded) return;
    final s = ref.read(profileProvider);
    if (!s.isLoading && s.packages.isEmpty) {
      _seeded = true;
      await _seedDefaultPackage();
    } else if (!s.isLoading) {
      _seeded = true;
    }
  }

  Future<void> _seedDefaultPackage() async {
    final notifier = ref.read(profileProvider.notifier);
    await notifier.addPackage(
      name: 'Стандартный пакет КЗ',
      description: 'Типовой набор документов для поступления в вузы Казахстана',
    );

    // After adding the package, seed its items.
    final pkgs = ref.read(profileProvider).packages;
    if (pkgs.isEmpty) return;
    final pkgId = pkgs.first.id;

    const items = [
      'Удостоверение личности / Свидетельство о рождении',
      'Аттестат / Транскрипт оценок',
      'Медицинская справка 086-У',
      'Фотографии 3×4 (6 шт.)',
      'Сертификат ЕНТ / ЕГЭ',
      'Сертификат IELTS / TOEFL / SAT (при наличии)',
      'Мотивационное письмо',
      'Рекомендательные письма (2 шт.)',
      'Заявление о поступлении',
    ];

    for (final label in items) {
      await notifier.addItemToPackage(packageId: pkgId, label: label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // Seed once packages are loaded and empty.
    if (!_seeded && !state.isLoading && state.packages.isEmpty) {
      _seeded = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _seedDefaultPackage(),
      );
    } else if (!_seeded && !state.isLoading) {
      _seeded = true;
    }

    return AppScaffold(
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapXl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    profile: state.profile,
                    tokens: tokens,
                    isEditing: _isEditing,
                    onToggleEdit: () =>
                        setState(() => _isEditing = !_isEditing),
                  ),
                  SizedBox(height: tokens.gapXxl),

                  // ── Section: Мои данные ────────────────────────────────
                  _SectionTitle(title: 'Мои данные', tokens: tokens),
                  SizedBox(height: tokens.gapMd),
                  if (_isEditing)
                    _SelfDataEditForm(
                      profile: state.profile,
                      tokens: tokens,
                      onSaved: () => setState(() => _isEditing = false),
                    )
                  else
                    _SelfDataView(profile: state.profile, tokens: tokens),
                  SizedBox(height: tokens.gapXxl),

                  // ── Career test CTA ────────────────────────────────────
                  _CareerTestCard(
                    careerResult: state.profile.careerResult,
                    tokens: tokens,
                  ),
                  SizedBox(height: tokens.gapXxl),

                  // ── Section: Пакет документов ──────────────────────────
                  _SectionTitle(title: 'Пакет документов', tokens: tokens),
                  SizedBox(height: tokens.gapSm),
                  Text(
                    'Отмечай документы по мере готовности и отправляй разом',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: tokens.gapMd),
                  _PackagesSection(packages: state.packages, tokens: tokens),

                  SizedBox(height: tokens.gapXxl),
                ],
              ),
            ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.tokens,
    required this.isEditing,
    required this.onToggleEdit,
  });

  final StudentProfile profile;
  final AppTokens tokens;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MascotSlot(size: 56, tag: 'profile_header'),
        SizedBox(width: tokens.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Профиль',
                style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
              ),
              Text(
                'Настройки и документы',
                style: textTheme.bodySmall,
              ),
              if (profile.careerResult != null) ...[
                SizedBox(height: tokens.gapXs),
                _CareerResultBadge(result: profile.careerResult!),
              ],
            ],
          ),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            onPressed: onToggleEdit,
            padding: EdgeInsets.zero,
            icon: Icon(
              isEditing ? Icons.close_rounded : Icons.edit_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _CareerResultBadge extends StatelessWidget {
  const _CareerResultBadge({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        result,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.tokens});
  final String title;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
    );
  }
}

// ── Self-data view (read-only) ────────────────────────────────────────────────

class _SelfDataView extends StatelessWidget {
  const _SelfDataView({required this.profile, required this.tokens});
  final StudentProfile profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DataRow(label: 'Имя', value: profile.name, tokens: tokens),
          _Divider(tokens: tokens),
          _DataRow(label: 'Класс', value: profile.grade, tokens: tokens),
          _Divider(tokens: tokens),
          _DataRow(label: 'Город', value: profile.city, tokens: tokens),
          _Divider(tokens: tokens),
          _DataRow(
            label: 'Средний балл',
            value: profile.gpa ?? profile.gpaBand,
            tokens: tokens,
          ),
          _Divider(tokens: tokens),
          _DataRow(
            label: 'Направления',
            value: profile.targetMajors.isEmpty
                ? null
                : profile.targetMajors.join(', '),
            tokens: tokens,
          ),
          _Divider(tokens: tokens),
          _DataRow(
            label: 'Интересы',
            value: profile.interests.isEmpty
                ? null
                : profile.interests.join(', '),
            tokens: tokens,
          ),
          _Divider(tokens: tokens),
          _DataRow(label: 'IELTS', value: profile.ieltsScore, tokens: tokens),
          _Divider(tokens: tokens),
          _DataRow(label: 'SAT', value: profile.satScore, tokens: tokens),
          _Divider(tokens: tokens),
          _DataRow(label: 'TOEFL', value: profile.toeflScore, tokens: tokens),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String? value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: textTheme.bodyLarge?.copyWith(
                color: value != null ? AppColors.ink : AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }
}

// ── Self-data edit form ───────────────────────────────────────────────────────

class _SelfDataEditForm extends ConsumerStatefulWidget {
  const _SelfDataEditForm({
    required this.profile,
    required this.tokens,
    required this.onSaved,
  });

  final StudentProfile profile;
  final AppTokens tokens;
  final VoidCallback onSaved;

  @override
  ConsumerState<_SelfDataEditForm> createState() => _SelfDataEditFormState();
}

class _SelfDataEditFormState extends ConsumerState<_SelfDataEditForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _gpaCtrl;
  late final TextEditingController _majorsCtrl;
  late final TextEditingController _interestsCtrl;
  late final TextEditingController _ieltsCtrl;
  late final TextEditingController _satCtrl;
  late final TextEditingController _toeflCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.name ?? '');
    _gradeCtrl = TextEditingController(text: p.grade ?? '');
    _cityCtrl = TextEditingController(text: p.city ?? '');
    _gpaCtrl = TextEditingController(text: p.gpa ?? p.gpaBand ?? '');
    _majorsCtrl = TextEditingController(text: p.targetMajors.join(', '));
    _interestsCtrl = TextEditingController(text: p.interests.join(', '));
    _ieltsCtrl = TextEditingController(text: p.ieltsScore ?? '');
    _satCtrl = TextEditingController(text: p.satScore ?? '');
    _toeflCtrl = TextEditingController(text: p.toeflScore ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    _cityCtrl.dispose();
    _gpaCtrl.dispose();
    _majorsCtrl.dispose();
    _interestsCtrl.dispose();
    _ieltsCtrl.dispose();
    _satCtrl.dispose();
    _toeflCtrl.dispose();
    super.dispose();
  }

  List<String> _split(String v) =>
      v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String? _nonEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  void _save() {
    final updated = widget.profile.copyWith(
      name: _nonEmpty(_nameCtrl.text),
      grade: _nonEmpty(_gradeCtrl.text),
      city: _nonEmpty(_cityCtrl.text),
      gpa: _nonEmpty(_gpaCtrl.text),
      targetMajors: _split(_majorsCtrl.text),
      interests: _split(_interestsCtrl.text),
      ieltsScore: _nonEmpty(_ieltsCtrl.text),
      satScore: _nonEmpty(_satCtrl.text),
      toeflScore: _nonEmpty(_toeflCtrl.text),
    );
    unawaited(ref.read(profileProvider.notifier).saveProfile(updated));
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Данные сохранены'),
        backgroundColor: AppColors.successGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.tokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileProvider.select((s) => s.isSaving));
    final tokens = widget.tokens;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EditField(
            label: 'Имя',
            hint: 'Как тебя зовут?',
            controller: _nameCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(label: 'Класс', hint: '11 класс', controller: _gradeCtrl),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'Город',
            hint: 'Алматы, Астана...',
            controller: _cityCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'Средний балл / ГПА',
            hint: '4.8',
            controller: _gpaCtrl,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'Направления (через запятую)',
            hint: 'IT, Медицина...',
            controller: _majorsCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'Интересы (через запятую)',
            hint: 'Математика, Дизайн...',
            controller: _interestsCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'IELTS балл',
            hint: '7.0',
            controller: _ieltsCtrl,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'SAT балл',
            hint: '1400',
            controller: _satCtrl,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: tokens.gapMd),
          _EditField(
            label: 'TOEFL балл',
            hint: '100',
            controller: _toeflCtrl,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: tokens.gapXl),
          PrimaryButton(
            label: 'Сохранить',
            onPressed: isSaving ? null : _save,
            isLoading: isSaving,
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
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

// ── Career test card ──────────────────────────────────────────────────────────

class _CareerTestCard extends StatelessWidget {
  const _CareerTestCard({
    required this.careerResult,
    required this.tokens,
  });

  final String? careerResult;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => _showConfirmDialog(context),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: tokens.gapMd),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пройти тест на профориентацию',
                  style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
                ),
                SizedBox(height: tokens.gapXs),
                Text(
                  careerResult != null
                      ? 'Результат: $careerResult. Пройти снова?'
                      : 'Займёт ~10–15 минут',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.inkSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Тест на профориентацию'),
        content: const Text(
          'Тест займёт 10–15 минут. Отвечай честно — так результат будет точнее.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context.push('/career-test'));
    }
  }
}

// ── Document packages section ─────────────────────────────────────────────────

class _PackagesSection extends ConsumerStatefulWidget {
  const _PackagesSection({required this.packages, required this.tokens});
  final List<DocumentPackage> packages;
  final AppTokens tokens;

  @override
  ConsumerState<_PackagesSection> createState() => _PackagesSectionState();
}

class _PackagesSectionState extends ConsumerState<_PackagesSection> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _createPackage() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    unawaited(
      ref
          .read(profileProvider.notifier)
          .addPackage(
            name: name,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
          ),
    );
    _nameCtrl.clear();
    _descCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final packages = widget.packages;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (packages.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: tokens.gapMd),
            itemBuilder: (context, i) =>
                _PackageCard(pkg: packages[i], tokens: tokens),
          ),
          SizedBox(height: tokens.gapMd),
        ],

        // Create new package
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Новый пакет',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapMd),
              _EditField(
                label: 'Название пакета',
                hint: 'Например: NU 2026',
                controller: _nameCtrl,
              ),
              SizedBox(height: tokens.gapMd),
              _EditField(
                label: 'Описание (необязательно)',
                hint: 'Документы для Назарбаев Университета',
                controller: _descCtrl,
              ),
              SizedBox(height: tokens.gapLg),
              PrimaryButton(
                label: 'Создать пакет',
                onPressed: _createPackage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends ConsumerWidget {
  const _PackageCard({required this.pkg, required this.tokens});
  final DocumentPackage pkg;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final checkedCount = pkg.items.where((i) => i.isAttached).length;
    final total = pkg.items.length;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pkg.name,
                  style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
                ),
              ),
              GestureDetector(
                onTap: () => unawaited(
                  ref.read(profileProvider.notifier).deletePackage(pkg.id),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorRed,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          if (pkg.description != null) ...[
            SizedBox(height: tokens.gapXs),
            Text(pkg.description!, style: textTheme.bodySmall),
          ],
          if (total > 0) ...[
            SizedBox(height: tokens.gapSm),
            Text(
              '$checkedCount / $total готово',
              style: textTheme.labelLarge?.copyWith(
                color: checkedCount == total
                    ? AppColors.successGreen
                    : AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: tokens.gapXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? checkedCount / total : 0,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.successGreen,
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.gapMd),
          ...pkg.items.map(
            (item) => _DocumentCheckRow(
              item: item,
              packageId: pkg.id,
              tokens: tokens,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCheckRow extends ConsumerWidget {
  const _DocumentCheckRow({
    required this.item,
    required this.packageId,
    required this.tokens,
  });

  final DocumentItem item;
  final String packageId;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => unawaited(
        ref
            .read(profileProvider.notifier)
            .toggleDocumentItem(
              packageId: packageId,
              itemId: item.id,
            ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.gapXs),
        child: Row(
          children: [
            Icon(
              item.isAttached
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: item.isAttached
                  ? AppColors.successGreen
                  : AppColors.inkSecondary,
              size: 22,
            ),
            SizedBox(width: tokens.gapSm),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: item.isAttached
                      ? AppColors.inkSecondary
                      : AppColors.ink,
                  decoration: item.isAttached
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
