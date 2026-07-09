import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// A single tab descriptor for [AppBottomNav].
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.isAccent = false,
    this.l10nKey,
  });

  /// Hardcoded fallback label (used when [l10nKey] is null or localizations
  /// are not available in the current context).
  final String label;
  final IconData icon;
  final IconData activeIcon;

  /// When true the tab is styled as the accent centre tab (Ералы).
  final bool isAccent;

  /// Optional ARB key for localizing the tab label.
  ///
  /// Supported values: `'sharedNavHome'`, `'sharedNavUniversities'`,
  /// `'sharedNavEraly'`, `'sharedNavOpportunities'`, `'sharedNavProfile'`.
  /// When non-null, [AppBottomNav] resolves the display label from
  /// [AppLocalizations]; [label] is only used as a fallback.
  final String? l10nKey;
}

/// Admity design-system bottom navigation bar (DESIGN_SYSTEM.md §5).
///
/// Five tabs: Главная / Курсы / Ералы⭐ / Возможности / Профиль.
/// The centre tab (index 2 — Ералы) is displayed with [AppColors.primary]
/// accent treatment.  All tabs are individually touch-target ≥ 48 px.
///
/// ## Animation (non-breaking addition)
/// The newly-selected tab icon scales up and the colour cross-fades from grey
/// to [AppColors.primary] using implicit animations.  The previously-selected
/// tab animates out in reverse.  Suppressed when
/// `MediaQuery.disableAnimations` is true (falls back to instant switch).
///
/// Reusable API (unchanged):
/// - [selectedIndex] — currently active tab index.
/// - [onTap] — called with the tapped index.
/// - [items] — list of [AppNavItem]s (must have exactly 5 for the design).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTab(
                    item: items[i],
                    isSelected: i == selectedIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.of(context).disableAnimations;

    final iconColor = isSelected ? AppColors.primary : AppColors.inkSecondary;
    final labelColor = iconColor;

    // Duration for colour / scale cross-fade.
    const animDuration = Duration(milliseconds: 200);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon — accent pill for the selected accent tab, animated icon
            // scale + colour cross-fade for all other tabs.
            if (item.isAccent && isSelected)
              AnimatedContainer(
                duration: disableAnim ? Duration.zero : animDuration,
                curve: Curves.easeOutCubic,
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.activeIcon,
                  color: AppColors.primary,
                  size: 22,
                ),
              )
            else
              AnimatedScale(
                scale: isSelected ? 1.18 : 1.0,
                duration: disableAnim ? Duration.zero : animDuration,
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: disableAnim ? Duration.zero : animDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    // Key forces AnimatedSwitcher to treat icon change as swap.
                    key: ValueKey<bool>(isSelected),
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: disableAnim ? Duration.zero : animDuration,
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: labelColor,
                height: 1,
              ),
              child: Text(
                _resolveLabel(context, item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves the display label for [item].
///
/// When `item.l10nKey` is set and [AppLocalizations] is available in `context`,
/// the localised string is returned.  Falls back to `item.label` otherwise.
String _resolveLabel(BuildContext context, AppNavItem item) {
  final key = item.l10nKey;
  if (key == null) return item.label;
  // Gracefully degrade if localizations are absent (e.g. bare widget tests).
  final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
  if (l10n == null) return item.label;
  return switch (key) {
    'sharedNavHome' => l10n.sharedNavHome,
    'sharedNavUniversities' => l10n.sharedNavUniversities,
    'sharedNavEraly' => l10n.sharedNavEraly,
    'sharedNavOpportunities' => l10n.sharedNavOpportunities,
    'sharedNavProfile' => l10n.sharedNavProfile,
    _ => item.label,
  };
}

/// Default five tabs matching DESIGN_SYSTEM.md §5.
///
/// Labels are resolved from [AppLocalizations] at build time via `l10nKey` so
/// they update automatically when the student switches the app language.
/// The `label` strings serve as compile-time fallbacks only.
const defaultNavItems = <AppNavItem>[
  AppNavItem(
    label: 'Главная',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    l10nKey: 'sharedNavHome',
  ),
  AppNavItem(
    label: 'Вузы',
    icon: Icons.account_balance_outlined,
    activeIcon: Icons.account_balance_rounded,
    l10nKey: 'sharedNavUniversities',
  ),
  AppNavItem(
    label: 'Ералы',
    icon: Icons.forum_outlined,
    activeIcon: Icons.forum_rounded,
    isAccent: true,
    l10nKey: 'sharedNavEraly',
  ),
  AppNavItem(
    label: 'Возможности',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    l10nKey: 'sharedNavOpportunities',
  ),
  AppNavItem(
    label: 'Профиль',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    l10nKey: 'sharedNavProfile',
  ),
];
