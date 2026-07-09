// Abroad universities list + detail screens.
//
// Sorting: major-matching universities appear first (profile.targetMajors),
// ties broken by fin-aid tier (need_blind_intl > generous_need_aware > limited)
// and then by lower tuition. No major overlap → sorted by fin-aid then tuition.

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/core/utils/external_link.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/universities/data/abroad_catalog_providers.dart';
import 'package:admity/features/universities/domain/abroad_university.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── List screen ────────────────────────────────────────────────────────────────

/// List screen showing all abroad universities, sorted by suitability.
///
/// Suitability order:
/// 1. Universities that overlap with `StudentProfile.targetMajors` come first.
/// 2. Within each group: better `FinAidTier` beats worse.
/// 3. Then lower `AbroadUniversity.tuitionUsdPerYear` (null last).
///
/// Navigates to `/uni-abroad/:id` on tap.
class AbroadUniversitiesScreen extends ConsumerWidget {
  /// Creates the abroad universities list screen.
  const AbroadUniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final catalogAsync = ref.watch(abroadUniversitiesProvider);
    final profile = ref.watch(profileProvider).profile;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.ink),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _MessageState(
          tokens: tokens,
          icon: Icons.cloud_off_rounded,
          message: 'Не удалось загрузить список зарубежных вузов',
        ),
        data: (universities) {
          if (universities.isEmpty) {
            return _MessageState(
              tokens: tokens,
              icon: Icons.public_off_rounded,
              message: 'Список зарубежных вузов пуст',
            );
          }

          final sorted = _sortedByProfile(
            universities,
            targetMajors: profile.targetMajors,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(count: sorted.length, tokens: tokens),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(tokens.screenPadding),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => SizedBox(height: tokens.gapMd),
                  itemBuilder: (context, i) {
                    final u = sorted[i];
                    final matchedMajors = _matchedMajors(
                      u.majors,
                      profile.targetMajors,
                    );
                    return _AbroadCard(
                      university: u,
                      matchedMajors: matchedMajors,
                      tokens: tokens,
                      onTap: () => context.push('/uni-abroad/${u.id}'),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 40 * (i % 12)),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Detail screen ──────────────────────────────────────────────────────────────

/// Detail screen for a single abroad university identified by [universityId].
class AbroadUniversityDetailScreen extends ConsumerWidget {
  /// Creates the abroad university detail screen for [universityId].
  const AbroadUniversityDetailScreen({
    required this.universityId,
    super.key,
  });

  /// Slug id of the university to show, e.g. `harvard`, `mit`.
  final String universityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final catalogAsync = ref.watch(abroadUniversitiesProvider);

    return catalogAsync.when(
      loading: () => const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => AppScaffold(
        body: _MessageState(
          tokens: tokens,
          icon: Icons.cloud_off_rounded,
          message: 'Не удалось загрузить данные',
        ),
      ),
      data: (universities) {
        AbroadUniversity? uni;
        for (final u in universities) {
          if (u.id == universityId) {
            uni = u;
            break;
          }
        }

        if (uni == null) {
          return AppScaffold(
            body: _MessageState(
              tokens: tokens,
              icon: Icons.school_outlined,
              message: 'Вуз не найден',
            ),
          );
        }

        return _DetailBody(university: uni, tokens: tokens);
      },
    );
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.university, required this.tokens});

  final AbroadUniversity university;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final u = university;
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.ink),
        title: Text(
          u.nameEn,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────────────────
            AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.inkSecondary,
                      ),
                      SizedBox(width: tokens.gapXs),
                      Text(
                        '${u.city}, ${u.country}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (u.rankingTier != null)
                        _Badge(
                          label: u.rankingTier!,
                          color: _rankColor(u.rankingTier),
                          tokens: tokens,
                        ),
                    ],
                  ),
                  if (u.notableFor != null) ...[
                    SizedBox(height: tokens.gapMd),
                    Text(
                      u.notableFor!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: tokens.gapLg),
            // ── Financial info ─────────────────────────────────────────────────
            Text(
              'Финансы',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: tokens.gapMd),
            AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (u.finAid != null)
                    _DetailRow(
                      label: 'Финансовая помощь',
                      value: finAidTierLabel(u.finAid!),
                      valueColor: _finAidColor(u.finAid),
                      tokens: tokens,
                    ),
                  if (u.tuitionUsdPerYear != null) ...[
                    Divider(
                      height: tokens.gapLg,
                      color: AppColors.border,
                    ),
                    _DetailRow(
                      label: 'Стоимость в год',
                      value: '\$${_formatPrice(u.tuitionUsdPerYear!)}',
                      tokens: tokens,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: tokens.gapLg),
            // ── Majors ─────────────────────────────────────────────────────────
            if (u.majors.isNotEmpty) ...[
              Text(
                'Направления',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapMd),
              Wrap(
                spacing: tokens.gapSm,
                runSpacing: tokens.gapSm,
                children: u.majors
                    .map(
                      (m) => _Badge(
                        label: _majorLabel(m),
                        color: AppColors.primary,
                        tokens: tokens,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: tokens.gapLg),
            ],
            // ── Source link note ───────────────────────────────────────────────
            if (u.sourceUrl != null)
              InkWell(
                onTap: () => openExternalLink(context, u.sourceUrl!),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Источник: ${u.sourceUrl}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: tokens.gapXl),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      final thousands = price ~/ 1000;
      final remainder = price % 1000;
      if (remainder == 0) return '${thousands}k';
      return '$thousands,${remainder ~/ 100}k';
    }
    return price.toString();
  }

  Color _rankColor(String? tier) {
    switch (tier) {
      case 'T1':
        return AppColors.primary;
      case 'T2':
        return AppColors.successGreen;
      default:
        return AppColors.inkSecondary;
    }
  }

  Color _finAidColor(FinAidTier? tier) {
    switch (tier) {
      case FinAidTier.needBlindIntl:
        return AppColors.successGreen;
      case FinAidTier.generousNeedAware:
        return AppColors.goldKey;
      case FinAidTier.limited:
      case FinAidTier.none:
      case null:
        return AppColors.inkSecondary;
    }
  }
}

// ── List header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.tokens});

  final int count;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.gapLg,
              tokens.screenPadding,
              tokens.gapMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вузы за рубежом',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.ink),
                      ),
                      SizedBox(height: tokens.gapXs),
                      Text(
                        '$count вузов мира',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.public_rounded,
                  size: 40,
                  color: AppColors.goldKey,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// ── Abroad card ───────────────────────────────────────────────────────────────

class _AbroadCard extends StatelessWidget {
  const _AbroadCard({
    required this.university,
    required this.matchedMajors,
    required this.tokens,
    required this.onTap,
  });

  final AbroadUniversity university;
  final List<String> matchedMajors;
  final AppTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final u = university;
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Campus photo (with dorm thumbnail overlay) ────────────────────
          if (u.imageUrl != null) ...[
            _CardImages(
              campusUrl: u.imageUrl!,
              dormUrl: u.dormImageUrl,
              tokens: tokens,
            ),
            SizedBox(height: tokens.gapSm),
          ],
          // ── Name row ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  u.nameEn,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (u.rankingTier != null) ...[
                SizedBox(width: tokens.gapSm),
                _Badge(
                  label: u.rankingTier!,
                  color: u.rankingTier == 'T1'
                      ? AppColors.primary
                      : AppColors.successGreen,
                  tokens: tokens,
                ),
              ],
            ],
          ),
          SizedBox(height: tokens.gapSm),
          // ── Location ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                '${u.city}, ${u.country}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          // ── Bottom row: major match, tuition, fin-aid, arrow ──────────────
          Row(
            children: [
              if (matchedMajors.isNotEmpty)
                _Badge(
                  label: 'совпадение',
                  color: AppColors.successGreen,
                  tokens: tokens,
                ),
              if (matchedMajors.isNotEmpty) SizedBox(width: tokens.gapSm),
              if (u.tuitionUsdPerYear != null)
                _Badge(
                  label: '\$${_shortPrice(u.tuitionUsdPerYear!)}/год',
                  color: AppColors.inkSecondary,
                  tokens: tokens,
                ),
              if (u.tuitionUsdPerYear != null && u.finAid != null)
                SizedBox(width: tokens.gapSm),
              if (u.finAid != null)
                _Badge(
                  label: _shortFinAidLabel(u.finAid!),
                  color: _finAidBadgeColor(u.finAid!),
                  tokens: tokens,
                ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortPrice(int price) {
    if (price >= 1000) {
      return '${price ~/ 1000}k';
    }
    return price.toString();
  }

  String _shortFinAidLabel(FinAidTier tier) {
    switch (tier) {
      case FinAidTier.needBlindIntl:
        return 'need-blind';
      case FinAidTier.generousNeedAware:
        return 'щедрые гранты';
      case FinAidTier.limited:
        return 'лимит. помощь';
      case FinAidTier.none:
        return 'без помощи';
    }
  }

  Color _finAidBadgeColor(FinAidTier tier) {
    switch (tier) {
      case FinAidTier.needBlindIntl:
        return AppColors.successGreen;
      case FinAidTier.generousNeedAware:
        return AppColors.goldKey;
      case FinAidTier.limited:
      case FinAidTier.none:
        return AppColors.inkSecondary;
    }
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.tokens,
    this.valueColor,
  });

  final String label;
  final String value;
  final AppTokens tokens;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        ),
        SizedBox(width: tokens.gapMd),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.tokens,
  });

  final String label;
  final Color color;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}

// ── Message state ─────────────────────────────────────────────────────────────

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.tokens,
    required this.icon,
    required this.message,
  });

  final AppTokens tokens;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.border),
            SizedBox(height: tokens.gapMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sorting helpers ───────────────────────────────────────────────────────────

/// Returns a sorted copy of [universities] most-suitable-first for the given
/// [targetMajors] profile.
///
/// Sort key (stable, three-level):
/// 1. Major overlap (any match beats no match).
/// 2. [FinAidTier] — lower [finAidSortOrder] is better.
/// 3. [AbroadUniversity.tuitionUsdPerYear] ascending (null = worst).
List<AbroadUniversity> _sortedByProfile(
  List<AbroadUniversity> universities, {
  required List<String> targetMajors,
}) {
  final lower = targetMajors.map((m) => m.toLowerCase()).toSet();

  int sortKey(AbroadUniversity u) {
    final hasMatch = u.majors.any((m) => lower.contains(m.toLowerCase()))
        ? 0
        : 1;
    final aid = u.finAid != null ? finAidSortOrder(u.finAid!) : 9;
    return hasMatch * 1000 + aid * 100;
  }

  final copy = [...universities];
  copy.sort((a, b) {
    final ka = sortKey(a);
    final kb = sortKey(b);
    if (ka != kb) return ka.compareTo(kb);
    // Tertiary: tuition ascending (null = ∞).
    final ta = a.tuitionUsdPerYear ?? 999999;
    final tb = b.tuitionUsdPerYear ?? 999999;
    return ta.compareTo(tb);
  });
  return copy;
}

/// Returns the subset of [majors] that are in [targetMajors] (case-insensitive).
List<String> _matchedMajors(List<String> majors, List<String> targetMajors) {
  final lower = targetMajors.map((m) => m.toLowerCase()).toSet();
  return majors.where((m) => lower.contains(m.toLowerCase())).toList();
}

/// Human-readable Russian label for a major token from universities_abroad.json.
String _majorLabel(String token) {
  switch (token) {
    case 'cs':
      return 'CS';
    case 'engineering':
      return 'Инженерия';
    case 'mathematics':
      return 'Математика';
    case 'physics':
      return 'Физика';
    case 'chemistry':
      return 'Химия';
    case 'biology':
      return 'Биология';
    case 'medicine':
      return 'Медицина';
    case 'economics':
      return 'Экономика';
    case 'business':
      return 'Бизнес';
    case 'psychology':
      return 'Психология';
    case 'politics':
      return 'Политология';
    default:
      return token;
  }
}

/// Campus photo header for an abroad-university card, with an optional
/// dormitory thumbnail overlaid in the bottom-right corner.
///
/// Both images degrade to nothing/placeholder on load errors — a broken URL
/// must never break the card.
class _CardImages extends StatelessWidget {
  const _CardImages({
    required this.campusUrl,
    required this.tokens,
    this.dormUrl,
  });

  final String campusUrl;
  final String? dormUrl;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: SizedBox(
        height: 132,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              campusUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.surfaceTint,
                child: Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            if (dormUrl != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 2),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          dormUrl!,
                          width: 72,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const SizedBox.shrink(),
                        ),
                        Container(
                          width: 72,
                          color: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: const Text(
                            'Общежитие',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
