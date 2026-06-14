import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// A titled section header with an optional trailing action and subtitle.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleLarge),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.textMuted),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
