import 'package:admity/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Temporary scaffold for not-yet-built features.
///
/// Deliberately follows the repo's render rules (see CLAUDE.md): a
/// `SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)` body, and
/// no `CrossAxisAlignment.stretch` inside the scroll view — those produce
/// silent blank screens on this codebase.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: tokens.brand),
              SizedBox(height: tokens.gapMd),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: tokens.gapSm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
