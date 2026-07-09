/// Profile screen — §7.7 DESIGN_SYSTEM.md.
///
/// Layout:
///   1. Identity header — name, career badge, daily goal.  Pencil icon opens
///      ProfileEditScreen (/profile/edit).  "Мои данные" form is NOT shown here.
///   2. Пакет документов — pre-seeded KZ pack (career-test card removed).
///   3. Пакет документов — pre-seeded KZ pack; each item shows attach/confirm
///      button (file_picker); missing items clearly distinguish from attached.
///
/// Anti-slop rules (DESIGN_SYSTEM.md §8 / CLAUDE.md):
///   - AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min)
///   - NEVER CrossAxisAlignment.stretch inside a scroll view
///   - Colors only AppColors, font only Onest via theme
///   - One accent per screen (AppColors.primary / cobalt)
library;

import 'dart:async';

import 'package:admity/core/l10n/l10n.dart';
import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/document_store.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSeed());
  }

  Future<void> _maybeSeed() async {
    if (_seeded) return;
    _seeded = true;
    await ref.read(profileProvider.notifier).ensureDefaultPackageSeeded();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // Also seed once the loading state resolves (handles the async race).
    if (!_seeded && !state.isLoading) {
      _seeded = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(profileProvider.notifier).ensureDefaultPackageSeeded(),
      );
    }

    return AppScaffold(
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.screenPadding,
                  vertical: tokens.gapXl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Identity header ─────────────────────────────────
                    _IdentityHeader(
                          profile: state.profile,
                          tokens: tokens,
                        )
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    SizedBox(height: tokens.gapXxl),

                    // ── 1.5 Путь психологических тестов ────────────────────
                    _PsytestsBanner(tokens: tokens),
                    SizedBox(height: tokens.gapXxl),

                    // ── 2. Пакет документов ────────────────────────────────
                    _SectionHeader(
                      title: 'Пакет документов',
                      subtitle:
                          'Отмечай документы по мере готовности и прикрепляй файлы',
                      tokens: tokens,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _PackagesSection(
                      packages: state.packages,
                      tokens: tokens,
                    ).animate().fadeIn(delay: 160.ms, duration: 350.ms),

                    SizedBox(height: tokens.gapXxl),

                    // ── 4. Мои документы ───────────────────────────────────
                    _SectionHeader(
                      title: 'Мои документы',
                      subtitle:
                          'Прикрепляй файлы, открывай и делись с куратором',
                      tokens: tokens,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _MyDocsSection(
                      attachedDocs: state.profile.attachedDocs,
                      tokens: tokens,
                    ).animate().fadeIn(delay: 240.ms, duration: 350.ms),

                    SizedBox(height: tokens.gapXxl),

                    // ── 5. Язык приложения ─────────────────────────────────
                    _SectionHeader(
                      title: context.l10n.languageSectionTitle,
                      tokens: tokens,
                    ),
                    SizedBox(height: tokens.gapMd),
                    _LanguageSection(
                      current: state.profile.appLanguage,
                      tokens: tokens,
                    ).animate().fadeIn(delay: 300.ms, duration: 350.ms),

                    SizedBox(height: tokens.gapXxl),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Identity header ───────────────────────────────────────────────────────────

/// Compact identity card: mascot + name + career badge + daily goal.
/// The pencil icon navigates to /profile/edit (full editor).
/// "Мои данные" inline form is intentionally absent from this screen.
class _IdentityHeader extends ConsumerWidget {
  const _IdentityHeader({
    required this.profile,
    required this.tokens,
  });

  final StudentProfile profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = profile.name?.isNotEmpty == true ? profile.name! : null;

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
              if (displayName != null) ...[
                SizedBox(height: tokens.gapXs),
                Text(
                  displayName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ] else ...[
                SizedBox(height: tokens.gapXs),
                Text(
                  'Добавь данные о себе →',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              // Career badge
              if (profile.careerResult != null) ...[
                SizedBox(height: tokens.gapXs),
                _CareerBadge(result: profile.careerResult!),
              ],
              // Daily goal chip
              if (profile.dailyGoalMinutes != null) ...[
                SizedBox(height: tokens.gapXs),
                _GoalChip(minutes: profile.dailyGoalMinutes!),
              ],
            ],
          ),
        ),
        // Pencil → opens full edit screen
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            onPressed: () => context.push('/profile/edit'),
            padding: EdgeInsets.zero,
            tooltip: 'Редактировать данные',
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _CareerBadge extends StatelessWidget {
  const _CareerBadge({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 14,
          color: AppColors.inkSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          'Цель: $minutes мин/день',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
        ),
      ],
    );
  }
}

// ── Psytests banner ───────────────────────────────────────────────────────────

/// Entry point to the psych-tests roadmap («Путь тестов», /psytests).
class _PsytestsBanner extends StatelessWidget {
  const _PsytestsBanner({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/psytests'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          SizedBox(width: tokens.gapLg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Открой свою профессию',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Путь из 12 тестов о тебе — проходи по одному в день',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkSecondary),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.tokens,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
        ),
        if (subtitle != null) ...[
          SizedBox(height: tokens.gapXs),
          Text(subtitle!, style: textTheme.bodySmall),
        ],
      ],
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
            itemBuilder: (_, i) =>
                _PackageCard(pkg: packages[i], tokens: tokens),
          ),
          SizedBox(height: tokens.gapMd),
        ],

        // Create new package card
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
    final attached = pkg.items.where((i) => i.isAttached).length;
    final total = pkg.items.length;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package name + delete
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
            // Progress label
            Text(
              '$attached / $total подтверждено',
              style: textTheme.labelLarge?.copyWith(
                color: attached == total
                    ? AppColors.successGreen
                    : AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: tokens.gapXs),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? attached / total : 0,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.successGreen,
                ),
              ),
            ),
            SizedBox(height: tokens.gapMd),
            // Document rows
            ...pkg.items.map(
              (item) => _DocumentRow(
                item: item,
                packageId: pkg.id,
                tokens: tokens,
              ),
            ),
          ],

          SizedBox(height: tokens.gapMd),
          _AddDocButton(onTap: () => _showAddDocumentSheet(context, pkg)),
        ],
      ),
    );
  }

  void _showAddDocumentSheet(BuildContext context, DocumentPackage pkg) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AddDocumentSheet(package: pkg),
      ),
    );
  }
}

/// A single document row inside a package card.
///
/// When a file is attached the row shows a green check + tappable file name
/// (opens in-app via the native preview) plus replace/remove actions. An empty
/// slot shows a grey outline + "Прикрепить" button and a remove action.
class _DocumentRow extends ConsumerWidget {
  const _DocumentRow({
    required this.item,
    required this.packageId,
    required this.tokens,
  });

  final DocumentItem item;
  final String packageId;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isAttached = item.isAttached;
    final hasFile = item.filePath != null && item.filePath!.isNotEmpty;

    Future<void> openDoc() async {
      if (!hasFile) return;
      final err = await ref.read(documentStoreProvider).open(item.filePath!);
      if (err != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }

    Future<void> replaceFile() async {
      await ref
          .read(profileProvider.notifier)
          .attachFileToItem(packageId: packageId, itemId: item.id);
    }

    void removeItem() {
      unawaited(
        ref
            .read(profileProvider.notifier)
            .removeItemFromPackage(packageId: packageId, itemId: item.id),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.gapXs),
      child: Row(
        children: [
          // Status icon
          Icon(
            isAttached
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isAttached ? AppColors.successGreen : AppColors.inkSecondary,
            size: 22,
          ),
          SizedBox(width: tokens.gapSm),

          // Label + file name (tappable to open when a file is attached)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hasFile ? () => unawaited(openDoc()) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: textTheme.bodyLarge?.copyWith(
                      color: isAttached
                          ? AppColors.inkSecondary
                          : AppColors.ink,
                    ),
                  ),
                  if (hasFile) ...[
                    const SizedBox(height: 2),
                    Text(
                      _fileName(item.filePath!),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.successGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: tokens.gapXs),

          // Actions: open (if file) · attach/replace · remove
          if (hasFile)
            _DocAction(
              icon: Icons.open_in_new_rounded,
              tooltip: 'Открыть',
              color: AppColors.primary,
              onTap: () => unawaited(openDoc()),
            )
          else
            _AttachButton(
              isAttached: isAttached,
              onTap: () => unawaited(replaceFile()),
              tokens: tokens,
            ),
          if (hasFile) ...[
            SizedBox(width: tokens.gapXs),
            _DocAction(
              icon: Icons.swap_horiz_rounded,
              tooltip: 'Заменить',
              color: AppColors.inkSecondary,
              onTap: () => unawaited(replaceFile()),
            ),
          ],
          SizedBox(width: tokens.gapXs),
          _DocAction(
            icon: Icons.close_rounded,
            tooltip: 'Убрать из пакета',
            color: AppColors.errorRed,
            onTap: removeItem,
          ),
        ],
      ),
    );
  }

  String _fileName(String path) {
    final parts = path.replaceAll(r'\', '/').split('/');
    return parts.isNotEmpty ? parts.last : path;
  }
}

class _AttachButton extends StatelessWidget {
  const _AttachButton({
    required this.isAttached,
    required this.onTap,
    required this.tokens,
  });

  final bool isAttached;
  final VoidCallback onTap;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAttached
              ? AppColors.successGreen.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(
            color: isAttached
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAttached ? Icons.swap_horiz_rounded : Icons.attach_file_rounded,
              size: 14,
              color: isAttached ? AppColors.successGreen : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              isAttached ? 'Заменить' : 'Прикрепить',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: isAttached ? AppColors.successGreen : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Documents section ──────────────────────────────────────────────────────

/// Displays the list of files stored in [StudentProfile.attachedDocs].
///
/// Each row shows the filename with three actions: open (via share sheet),
/// share, and delete.  A "Прикрепить файл" button invokes [DocumentStore.pickAndSave].
class _MyDocsSection extends ConsumerStatefulWidget {
  const _MyDocsSection({
    required this.attachedDocs,
    required this.tokens,
  });

  final List<String> attachedDocs;
  final AppTokens tokens;

  @override
  ConsumerState<_MyDocsSection> createState() => _MyDocsSectionState();
}

class _MyDocsSectionState extends ConsumerState<_MyDocsSection> {
  bool _busy = false;

  Future<void> _pickFile() async {
    if (_busy) return;
    setState(() => _busy = true);
    final store = ref.read(documentStoreProvider);
    await store.pickAndSave();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final docs = widget.attachedDocs;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (docs.isEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.folder_open_outlined,
                  color: AppColors.inkSecondary,
                  size: 22,
                ),
                SizedBox(width: tokens.gapSm),
                Expanded(
                  child: Text(
                    'Нет прикреплённых файлов',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.gapMd),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (_, i) => _DocRow(
                path: docs[i],
                tokens: tokens,
              ),
            ),
            SizedBox(height: tokens.gapMd),
          ],

          // Attach button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _pickFile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.attach_file_rounded, size: 18),
              label: Text(
                'Прикрепить файл',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single row for an attached document file.
///
/// Shows the filename (truncated), plus open/share/delete actions.
class _DocRow extends ConsumerWidget {
  const _DocRow({required this.path, required this.tokens});

  final String path;
  final AppTokens tokens;

  /// Extracts the display name — strips the timestamp prefix added by
  /// [DocumentStore.pickAndSave] (e.g. `1234567890_resume.pdf` → `resume.pdf`).
  String _displayName(String filePath) {
    final parts = filePath.replaceAll(r'\', '/').split('/');
    final raw = parts.isNotEmpty ? parts.last : filePath;
    // Strip leading timestamp prefix (<digits>_) if present.
    final match = RegExp(r'^\d+_(.+)$').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final store = ref.read(documentStoreProvider);
    final name = _displayName(path);

    Future<void> openDoc() async {
      final err = await store.open(path);
      if (err != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.inkSecondary,
            size: 20,
          ),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => unawaited(openDoc()),
              child: Text(
                name,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: tokens.gapXs),

          // Open inside the app (Quick Look / native preview).
          _DocAction(
            icon: Icons.open_in_new_rounded,
            tooltip: 'Открыть',
            color: AppColors.primary,
            onTap: () => unawaited(openDoc()),
          ),
          SizedBox(width: tokens.gapXs),

          // Share
          _DocAction(
            icon: Icons.share_outlined,
            tooltip: 'Поделиться',
            color: AppColors.inkSecondary,
            onTap: () => unawaited(store.share(path)),
          ),
          SizedBox(width: tokens.gapXs),

          // Delete
          _DocAction(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Удалить',
            color: AppColors.errorRed,
            onTap: () => unawaited(store.delete(path)),
          ),
        ],
      ),
    );
  }
}

/// A compact icon-button used by [_DocRow].
class _DocAction extends StatelessWidget {
  const _DocAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Tooltip(
          message: tooltip,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ── Add-document button + sheet ───────────────────────────────────────────────

/// Full-width "Добавить документ" button shown inside each package card.
class _AddDocButton extends StatelessWidget {
  const _AddDocButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          'Добавить документ',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Bottom sheet to add a document to a [DocumentPackage].
///
/// Three paths, matching the student's mental model:
///   • "Загрузить новый файл" — picks + saves a file (also lands in
///     «Мои документы» so it is reusable).
///   • "Добавить пункт без файла" — a labelled slot to attach later.
///   • "Из моих документов" — reuse a file the student already saved.
class _AddDocumentSheet extends ConsumerStatefulWidget {
  const _AddDocumentSheet({required this.package});

  final DocumentPackage package;

  @override
  ConsumerState<_AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends ConsumerState<_AddDocumentSheet> {
  bool _busy = false;

  /// Strips the timestamp prefix added by [DocumentStore.pickAndSave].
  String _displayName(String path) {
    final parts = path.replaceAll(r'\', '/').split('/');
    final raw = parts.isNotEmpty ? parts.last : path;
    final match = RegExp(r'^\d+_(.+)$').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  Future<void> _uploadNew() async {
    if (_busy) return;
    setState(() => _busy = true);
    final path = await ref.read(documentStoreProvider).pickAndSave();
    if (path != null) {
      await ref
          .read(profileProvider.notifier)
          .addExistingDocToPackage(
            packageId: widget.package.id,
            filePath: path,
            label: _displayName(path),
          );
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (path != null) Navigator.of(context).pop();
  }

  Future<void> _addExisting(String path) async {
    await ref
        .read(profileProvider.notifier)
        .addExistingDocToPackage(
          packageId: widget.package.id,
          filePath: path,
          label: _displayName(path),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addLabelSlot() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Новый пункт'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Например: Рекомендательное письмо',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (label != null && label.isNotEmpty) {
      await ref
          .read(profileProvider.notifier)
          .addItemToPackage(packageId: widget.package.id, label: label);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final textTheme = Theme.of(context).textTheme;
    final attachedDocs = ref.watch(profileProvider).profile.attachedDocs;
    final usedPaths = widget.package.items
        .map((i) => i.filePath)
        .whereType<String>()
        .toSet();
    final available = attachedDocs
        .where((p) => !usedPaths.contains(p))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.gapLg,
          tokens.screenPadding,
          tokens.gapLg,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добавить документ',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                'в пакет «${widget.package.name}»',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tokens.gapLg),

              _SheetAction(
                icon: Icons.upload_file_rounded,
                label: 'Загрузить новый файл',
                busy: _busy,
                onTap: () => unawaited(_uploadNew()),
              ),
              SizedBox(height: tokens.gapSm),
              _SheetAction(
                icon: Icons.playlist_add_rounded,
                label: 'Добавить пункт без файла',
                onTap: () => unawaited(_addLabelSlot()),
              ),

              SizedBox(height: tokens.gapLg),
              if (available.isNotEmpty) ...[
                Text(
                  'Из моих документов',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
                ),
                SizedBox(height: tokens.gapSm),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: available.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) {
                      final path = available[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColors.inkSecondary,
                        ),
                        title: Text(
                          _displayName(path),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                        ),
                        onTap: () => unawaited(_addExisting(path)),
                      );
                    },
                  ),
                ),
              ] else
                Text(
                  'Пока нет сохранённых файлов. Загрузи новый — он появится и '
                  'в разделе «Мои документы».',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A left-aligned, full-width action button used inside [_AddDocumentSheet].
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── Language section ──────────────────────────────────────────────────────────

/// UI-language picker: system default (device / Apple ID language), Russian,
/// Kazakh or English. Persists to `StudentProfile.appLanguage`; the app
/// rebuilds instantly because `AdmityApp` watches [appLocaleProvider].
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection({required this.current, required this.tokens});

  final String current;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final options = <(String, String)>[
      ('system', l10n.languageSystem),
      ('kk', l10n.languageKazakh),
      ('ru', l10n.languageRussian),
      ('en', l10n.languageEnglish),
    ];

    return AppCard(
      child: Wrap(
        spacing: tokens.gapSm,
        runSpacing: tokens.gapSm,
        children: [
          for (final (code, label) in options)
            ChoiceChip(
              label: Text(label),
              selected: current == code,
              onSelected: (_) {
                final profile = ref.read(profileProvider).profile;
                unawaited(
                  ref
                      .read(profileProvider.notifier)
                      .saveProfile(profile.copyWith(appLanguage: code)),
                );
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: current == code ? AppColors.primary : AppColors.ink,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                side: BorderSide(
                  color: current == code ? AppColors.primary : AppColors.border,
                ),
              ),
              backgroundColor: AppColors.white,
              showCheckmark: false,
            ),
        ],
      ),
    );
  }
}

// ── Shared text field ─────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  const _EditField({
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
