import 'package:flutter/material.dart';

/// Temporary scaffold for not-yet-built tabs/screens.
///
/// Follows the repo render rules (CLAUDE.md): a
/// `SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)` body and no
/// `CrossAxisAlignment.stretch` inside the scroll view — those produce silent
/// blank screens on this codebase.
///
/// Intentionally depends only on Flutter Material (no AppTokens), so Phase 0's
/// design-system work can rebuild the theme without breaking these.
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
