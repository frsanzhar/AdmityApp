import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders a Riverpod [AsyncValue] with consistent loading / error / data
/// states so features don't reinvent them.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.loading,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: context.tokens.textMuted,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Не удалось загрузить данные',
                style: context.text.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple shimmer-free skeleton block for loading states.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.height = 16,
    this.width = double.infinity,
    this.radius = 8,
    super.key,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.tokens.surfaceSunken,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
