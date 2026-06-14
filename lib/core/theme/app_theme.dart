import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds the app's light and dark [ThemeData] from the design tokens.
///
/// Warm, editorial, calm — terracotta primary, sand/graphite surfaces, soft
/// rounded cards with a branded shadow, and no default-Material purple.
abstract final class AppTheme {
  /// Warm light theme.
  static ThemeData get light => _build(Brightness.light);

  /// Warm dark theme (dark-first intent; tuned for OLED-friendly warm graphite).
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: brightness,
      primary: AppColors.terracotta,
      secondary: AppColors.teal,
      tertiary: AppColors.amber,
      surface: isLight ? AppColors.sand : AppColors.graphite,
      error: AppColors.clay,
    );

    final onSurface = isLight ? AppColors.inkLight : AppColors.inkDark;
    final tokens = isLight ? AppTokens.light() : AppTokens.dark();
    final textTheme = AppTypography.textTheme(onSurface);

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: [tokens],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: tokens.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: tokens.surfaceRaised,
        selectedColor: AppColors.terracotta,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceSunken,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: AppColors.terracotta, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surfaceRaised,
        indicatorColor: AppColors.terracotta.withValues(alpha: 0.18),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        height: 68,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.terracotta,
      ),
    );
  }
}
