import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Top-level scaffold wrapper that enforces SafeArea and a consistent
/// white background across all Admity screens.
///
/// Do NOT add [CrossAxisAlignment.stretch] to any child column inside a
/// scroll view — see CLAUDE.md for why that causes silent blank screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? AppColors.white,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(child: body),
    );
  }
}
