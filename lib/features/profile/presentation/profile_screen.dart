/// Profile screen — §7.7 DESIGN_SYSTEM.md.
///
/// Sections:
///   1. Edit self-data (изменить/добавить/сохранить) — persisted via [ProfileNotifier].
///   2. Notes about self (заметки) — add/edit/delete, persisted locally.
///   3. Documents as a «пакет» — assemble a package of document items.
///
/// Layout anti-slop rules (CLAUDE.md):
///   - AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min)
///   - NEVER CrossAxisAlignment.stretch inside a scroll view
///   - Colors only from AppColors, font only Onest via theme
///   - ONE accent per screen (primary cobalt)
///   - Dark PrimaryButton for Save actions; FeaturedButton only for featured CTA
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
                  _ProfileHeader(tokens: tokens),
                  SizedBox(height: tokens.gapXxl),

                  // ── Section 1: Self-data form ──────────────────────────
                  _SectionTitle(title: 'Мои данные', tokens: tokens),
                  SizedBox(height: tokens.gapMd),
                  _SelfDataForm(profile: state.profile, tokens: tokens),
                  SizedBox(height: tokens.gapXxl),

                  // ── Section 2: Notes ───────────────────────────────────
                  _SectionTitle(title: 'Заметки о себе', tokens: tokens),
                  SizedBox(height: tokens.gapMd),
                  _NotesSection(notes: state.notes, tokens: tokens),
                  SizedBox(height: tokens.gapXxl),

                  // ── Section 3: Document packages ───────────────────────
                  _SectionTitle(title: 'Пакеты документов', tokens: tokens),
                  SizedBox(height: tokens.gapSm),
                  Text(
                    'Собери документы в пакет и отправляй разом без возни',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: tokens.gapMd),
                  _PackagesSection(packages: state.packages, tokens: tokens),

                  // Bottom safe-area padding
                  SizedBox(height: tokens.gapXxl),
                ],
              ),
            ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TODO(mascot): replace with actual mascot asset
        const MascotSlot(size: 56, tag: 'profile_header'),
        SizedBox(width: tokens.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Профиль',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              Text(
                'Настройки, заметки, документы',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
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
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.ink,
          ),
    );
  }
}

// ── Self-data form ────────────────────────────────────────────────────────────

class _SelfDataForm extends ConsumerStatefulWidget {
  const _SelfDataForm({required this.profile, required this.tokens});
  final StudentProfile profile;
  final AppTokens tokens;

  @override
  ConsumerState<_SelfDataForm> createState() => _SelfDataFormState();
}

class _SelfDataFormState extends ConsumerState<_SelfDataForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _gpaBandCtrl;
  late final TextEditingController _languagesCtrl;
  late final TextEditingController _universitiesCtrl;
  late final TextEditingController _majorsCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.name ?? '');
    _gradeCtrl = TextEditingController(text: p.grade ?? '');
    _cityCtrl = TextEditingController(text: p.city ?? '');
    _gpaBandCtrl = TextEditingController(text: p.gpaBand ?? '');
    _languagesCtrl = TextEditingController(
      text: p.languages.join(', '),
    );
    _universitiesCtrl = TextEditingController(
      text: p.targetUniversities.join(', '),
    );
    _majorsCtrl = TextEditingController(
      text: p.targetMajors.join(', '),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    _cityCtrl.dispose();
    _gpaBandCtrl.dispose();
    _languagesCtrl.dispose();
    _universitiesCtrl.dispose();
    _majorsCtrl.dispose();
    super.dispose();
  }

  List<String> _split(String v) =>
      v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _save() {
    final updated = widget.profile.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      grade: _gradeCtrl.text.trim().isEmpty ? null : _gradeCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      gpaBand:
          _gpaBandCtrl.text.trim().isEmpty ? null : _gpaBandCtrl.text.trim(),
      languages: _split(_languagesCtrl.text),
      targetUniversities: _split(_universitiesCtrl.text),
      targetMajors: _split(_majorsCtrl.text),
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
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      profileProvider.select((s) => s.isSaving),
    );
    final tokens = widget.tokens;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Имя',
            hint: 'Как тебя зовут?',
            controller: _nameCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Класс',
            hint: 'Например: 11 класс',
            controller: _gradeCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Город',
            hint: 'Алматы, Астана...',
            controller: _cityCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Средний балл (диапазон)',
            hint: '4.5–5.0',
            controller: _gpaBandCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Языки (через запятую)',
            hint: 'KZ, RU, EN',
            controller: _languagesCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Целевые университеты (через запятую)',
            hint: 'NU, KBTU, SDU...',
            controller: _universitiesCtrl,
          ),
          SizedBox(height: tokens.gapMd),
          _FormField(
            label: 'Направления (через запятую)',
            hint: 'IT, Медицина, Финансы...',
            controller: _majorsCtrl,
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

// ── Small form-field widget ───────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
  });
  final String label;
  final String hint;
  final TextEditingController controller;

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

// ── Notes section ─────────────────────────────────────────────────────────────

class _NotesSection extends ConsumerStatefulWidget {
  const _NotesSection({required this.notes, required this.tokens});
  final List<ProfileNote> notes;
  final AppTokens tokens;

  @override
  ConsumerState<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends ConsumerState<_NotesSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addNote() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    unawaited(ref.read(profileProvider.notifier).addNote(text));
    _ctrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final notes = widget.notes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add-note input row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 3,
                minLines: 1,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.ink,
                    ),
                decoration: InputDecoration(
                  hintText: 'Добавить заметку...',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: tokens.gapSm),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                onPressed: _addNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: const Icon(Icons.add_rounded, size: 22),
              ),
            ),
          ],
        ),

        if (notes.isNotEmpty) ...[
          SizedBox(height: tokens.gapMd),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.gapSm),
            itemBuilder: (context, i) => _NoteCard(
              note: notes[i],
              tokens: tokens,
            ),
          ),
        ],
      ],
    );
  }
}

class _NoteCard extends ConsumerStatefulWidget {
  const _NoteCard({required this.note, required this.tokens});
  final ProfileNote note;
  final AppTokens tokens;

  @override
  ConsumerState<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<_NoteCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.note.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return AppCard(
      padding: EdgeInsets.all(tokens.gapMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editing) ...[
            TextField(
              controller: _ctrl,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: tokens.gapSm),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _editing = false);
                  },
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  label: 'Сохранить',
                  width: 120,
                  onPressed: () {
                    unawaited(
                      ref.read(profileProvider.notifier).editNote(
                            widget.note.id,
                            _ctrl.text,
                          ),
                    );
                    setState(() => _editing = false);
                  },
                ),
              ],
            ),
          ] else ...[
            Text(
              widget.note.text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: tokens.gapSm),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Text(
                    'Изменить',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
                SizedBox(width: tokens.gapMd),
                GestureDetector(
                  onTap: () => unawaited(
                    ref.read(profileProvider.notifier).deleteNote(widget.note.id),
                  ),
                  child: Text(
                    'Удалить',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.errorRed,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
      ref.read(profileProvider.notifier).addPackage(
            name: name,
            description:
                _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
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
        // Create new package card
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Новый пакет',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              SizedBox(height: tokens.gapMd),
              _FormField(
                label: 'Название пакета',
                hint: 'Например: NU 2026',
                controller: _nameCtrl,
              ),
              SizedBox(height: tokens.gapMd),
              _FormField(
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

        if (packages.isNotEmpty) ...[
          SizedBox(height: tokens.gapMd),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.gapMd),
            itemBuilder: (context, i) => _PackageCard(
              pkg: packages[i],
              tokens: tokens,
            ),
          ),
        ],
      ],
    );
  }
}

class _PackageCard extends ConsumerStatefulWidget {
  const _PackageCard({required this.pkg, required this.tokens});
  final DocumentPackage pkg;
  final AppTokens tokens;

  @override
  ConsumerState<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends ConsumerState<_PackageCard> {
  final _itemLabelCtrl = TextEditingController();

  @override
  void dispose() {
    _itemLabelCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final label = _itemLabelCtrl.text.trim();
    if (label.isEmpty) return;
    unawaited(
      ref.read(profileProvider.notifier).addItemToPackage(
            packageId: widget.pkg.id,
            label: label,
          ),
    );
    _itemLabelCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final pkg = widget.pkg;
    final textTheme = Theme.of(context).textTheme;

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
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                  size: 22,
                ),
              ),
            ],
          ),
          if (pkg.description != null) ...[
            SizedBox(height: tokens.gapXs),
            Text(pkg.description!, style: textTheme.bodySmall),
          ],
          SizedBox(height: tokens.gapMd),

          // Document items
          if (pkg.items.isNotEmpty) ...[
            ...pkg.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: tokens.gapSm),
                child: _DocumentItemRow(
                  item: item,
                  packageId: pkg.id,
                  tokens: tokens,
                ),
              ),
            ),
            SizedBox(height: tokens.gapSm),
          ],

          // Add item row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _itemLabelCtrl,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Транскрипт, рекомендация...',
                    hintStyle: textTheme.bodyLarge
                        ?.copyWith(color: AppColors.inkSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceTint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
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
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(width: tokens.gapSm),
              SizedBox(
                height: 44,
                width: 44,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentItemRow extends ConsumerWidget {
  const _DocumentItemRow({
    required this.item,
    required this.packageId,
    required this.tokens,
  });
  final DocumentItem item;
  final String packageId;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(
          item.isAttached
              ? Icons.check_circle_outline_rounded
              : Icons.radio_button_unchecked_rounded,
          color: item.isAttached ? AppColors.successGreen : AppColors.inkSecondary,
          size: 18,
        ),
        SizedBox(width: tokens.gapSm),
        Expanded(
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.ink,
                ),
          ),
        ),
        // TODO(files): wire file picker here
        GestureDetector(
          onTap: () => unawaited(
            ref.read(profileProvider.notifier).removeItemFromPackage(
                  packageId: packageId,
                  itemId: item.id,
                ),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.inkSecondary,
            size: 18,
          ),
        ),
      ],
    );
  }
}
