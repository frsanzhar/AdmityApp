import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand-specific semantic tokens that don't fit Material's [ColorScheme]:
/// XP/streak accents, the gamification palette, chancing-category colors and
/// the soft branded shadow. Access via `Theme.of(context).extension<AppTokens>()!`
/// or the [AppTokensX] helper.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.xp,
    required this.streak,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.textMuted,
    required this.chanceReach,
    required this.chanceTarget,
    required this.chanceLikely,
    required this.cardShadow,
  });

  /// Light token set.
  factory AppTokens.light() => const AppTokens(
        xp: AppColors.amber,
        streak: AppColors.burntOrange,
        success: AppColors.olive,
        warning: AppColors.burntOrange,
        danger: AppColors.clay,
        info: AppColors.teal,
        surfaceRaised: AppColors.cream,
        surfaceSunken: AppColors.sandAlt,
        textMuted: AppColors.inkMutedLight,
        chanceReach: AppColors.clay,
        chanceTarget: AppColors.teal,
        chanceLikely: AppColors.olive,
        cardShadow: Color(0x1A6B4A2E),
      );

  /// Dark token set.
  factory AppTokens.dark() => const AppTokens(
        xp: AppColors.amber,
        streak: AppColors.amberSoft,
        success: AppColors.olive,
        warning: AppColors.burntOrange,
        danger: AppColors.clay,
        info: AppColors.tealSoft,
        surfaceRaised: AppColors.graphiteRaised,
        surfaceSunken: AppColors.graphiteAlt,
        textMuted: AppColors.inkMutedDark,
        chanceReach: Color(0xFFE07A5F),
        chanceTarget: AppColors.tealSoft,
        chanceLikely: Color(0xFF9DB35F),
        cardShadow: Color(0x33000000),
      );

  final Color xp;
  final Color streak;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color textMuted;
  final Color chanceReach;
  final Color chanceTarget;
  final Color chanceLikely;
  final Color cardShadow;

  @override
  AppTokens copyWith({
    Color? xp,
    Color? streak,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? textMuted,
    Color? chanceReach,
    Color? chanceTarget,
    Color? chanceLikely,
    Color? cardShadow,
  }) {
    return AppTokens(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      textMuted: textMuted ?? this.textMuted,
      chanceReach: chanceReach ?? this.chanceReach,
      chanceTarget: chanceTarget ?? this.chanceTarget,
      chanceLikely: chanceLikely ?? this.chanceLikely,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      xp: Color.lerp(xp, other.xp, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      chanceReach: Color.lerp(chanceReach, other.chanceReach, t)!,
      chanceTarget: Color.lerp(chanceTarget, other.chanceTarget, t)!,
      chanceLikely: Color.lerp(chanceLikely, other.chanceLikely, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

/// Ergonomic access to [AppTokens] and the text theme from a [BuildContext].
extension AppTokensX on BuildContext {
  /// Brand semantic tokens for the current theme.
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;

  /// The active [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The active [TextTheme].
  TextTheme get text => Theme.of(this).textTheme;
}
