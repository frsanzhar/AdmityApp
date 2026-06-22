/// Profile screen — §7.7 DESIGN_SYSTEM.md.
///
/// Layout:
///   1. Identity header — name, career badge, daily goal.  Pencil icon opens
///      ProfileEditScreen (/profile/edit).  "Мои данные" form is NOT shown here.
///   2. Профориентация card — navigates to /career-test.
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

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
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

                    // ── 2. Career test CTA ─────────────────────────────────
                    _CareerTestCard(
                      careerResult: state.profile.careerResult,
                      tokens: tokens,
                    ).animate().fadeIn(
                      delay: 80.ms,
                      duration: 350.ms,
                    ),
                    SizedBox(height: tokens.gapXxl),

                    // ── 3. Пакет документов ────────────────────────────────
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
                  'Тест на профориентацию',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        ],
      ),
    );
  }
}

/// A single document row inside a package card.
///
/// Shows attached status clearly: green check + file name when attached;
/// grey outline + "Прикрепить" button when missing.
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

          // Label + file name
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isAttached ? AppColors.inkSecondary : AppColors.ink,
                    decoration: isAttached
                        ? TextDecoration.none
                        : TextDecoration.none,
                  ),
                ),
                if (isAttached && item.filePath != null) ...[
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

          SizedBox(width: tokens.gapSm),

          // Attach / re-attach button
          _AttachButton(
            isAttached: isAttached,
            onTap: () async {
              final picked = await ref
                  .read(profileProvider.notifier)
                  .attachFileToItem(
                    packageId: packageId,
                    itemId: item.id,
                  );
              // If file picker returned nothing but we still want to mark
              // this as confirmed via toggle, do nothing extra — user must
              // pick a file to confirm.
              if (!picked) {
                // User cancelled — no action.
              }
            },
            tokens: tokens,
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
