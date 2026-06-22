import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animated branching-knowledge diagram for onboarding.
///
/// A single glowing origin point sprouts branches that sweep outward
/// across the canvas. Each branch tip reveals a colored node.
/// Call [KnowledgeBranchDiagramController.reveal] to trigger the animation,
/// or pass [autoPlay] to start immediately on mount.
///
/// The widget respects `MediaQuery.disableAnimations` — when true the
/// fully-revealed state is shown instantly.
///
/// Usage:
/// ```dart
/// KnowledgeBranchDiagram(autoPlay: true)
///
/// // or with a controller:
/// final ctrl = KnowledgeBranchDiagramController();
/// KnowledgeBranchDiagram(controller: ctrl)
/// ctrl.reveal();
/// ```
class KnowledgeBranchDiagram extends StatefulWidget {
  const KnowledgeBranchDiagram({
    super.key,
    this.controller,
    this.autoPlay = true,
  });

  final KnowledgeBranchDiagramController? controller;

  /// When true the reveal animation plays automatically after mount.
  final bool autoPlay;

  @override
  State<KnowledgeBranchDiagram> createState() => _KnowledgeBranchDiagramState();
}

class KnowledgeBranchDiagramController extends ChangeNotifier {
  /// Trigger the reveal animation (or restart it).
  void reveal() => notifyListeners();
}

class _KnowledgeBranchDiagramState extends State<KnowledgeBranchDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  // Branch spec: angle (rad), length fraction (0-1), color, sub-branch offset angle.
  static final List<_Branch> _branches = [
    const _Branch(
      angle: -math.pi / 2,
      len: 0.38,
      color: AppColors.accentLime,
      children: [-0.45, 0.45],
    ),
    _Branch(
      angle: -math.pi / 2 + 0.9,
      len: 0.34,
      color: AppColors.ctaGradient[1],
      children: [-0.5, 0.3],
    ),
    const _Branch(
      angle: -math.pi / 2 + 1.9,
      len: 0.30,
      color: AppColors.successGreen,
      children: [0.4],
    ),
    const _Branch(
      angle: -math.pi / 2 + 2.9,
      len: 0.32,
      color: AppColors.goldKey,
      children: [-0.35, 0.5],
    ),
    _Branch(
      angle: -math.pi / 2 + 3.8,
      len: 0.35,
      color: AppColors.ctaGradient[2],
      children: [-0.4],
    ),
    const _Branch(
      angle: -math.pi / 2 + 4.7,
      len: 0.31,
      color: AppColors.primary,
      children: [0.45, -0.3],
    ),
    _Branch(
      angle: -math.pi / 2 + 5.6,
      len: 0.29,
      color: AppColors.ctaGradient[3],
      children: [0.35],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    widget.controller?.addListener(_onControllerNotified);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final disableAnim =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnim) {
        _ctrl.value = 1.0;
      } else if (widget.autoPlay) {
        unawaited(_ctrl.forward());
      }
    });
  }

  void _onControllerNotified() {
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnim) {
      _ctrl.value = 1.0;
    } else {
      _ctrl.reset();
      unawaited(_ctrl.forward());
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerNotified);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => CustomPaint(
        painter: _BranchPainter(
          branches: _branches,
          progress: _progress.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Branch {
  const _Branch({
    required this.angle,
    required this.len,
    required this.color,
    this.children = const [],
  });
  final double angle;
  final double len;
  final Color color;

  /// Angle offsets (radians) for sub-branches originating at the tip.
  final List<double> children;
}

class _BranchPainter extends CustomPainter {
  _BranchPainter({required this.branches, required this.progress});

  final List<_Branch> branches;

  /// 0 = nothing drawn, 1 = fully revealed.
  final double progress;

  static const double _subLen = 0.13;
  static const double _subNodeR = 5;
  static const double _mainNodeR = 10;
  static const double _originR = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.55);
    final maxLen = math.min(size.width, size.height) * 0.5;

    // Origin glow
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = AppColors.primary.withValues(alpha: 0.35 * progress);
    canvas.drawCircle(origin, _originR * 2.2, glowPaint);
    canvas.drawCircle(
      origin,
      _originR,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ).createShader(
              Rect.fromCircle(center: origin, radius: _originR),
            ),
    );
    canvas.drawCircle(origin, _originR * 0.4, Paint()..color = AppColors.white);

    for (var i = 0; i < branches.length; i++) {
      final b = branches[i];
      // Stagger each branch: branch i starts when progress > i * stagger.
      const stagger = 0.08;
      final branchStart = i * stagger;
      final branchProgress = ((progress - branchStart) / (1.0 - branchStart))
          .clamp(0.0, 1.0);

      if (branchProgress <= 0) continue;

      final tipX =
          origin.dx + math.cos(b.angle) * b.len * maxLen * branchProgress;
      final tipY =
          origin.dy + math.sin(b.angle) * b.len * maxLen * branchProgress;
      final tip = Offset(tipX, tipY);

      // Main branch line
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = b.color.withValues(alpha: 0.55);
      canvas.drawLine(origin, tip, linePaint);

      // Tip node (appears when branchProgress > 0.8)
      final nodeAlpha = ((branchProgress - 0.8) / 0.2).clamp(0.0, 1.0);
      if (nodeAlpha > 0) {
        final nodePaint = Paint()..color = b.color.withValues(alpha: nodeAlpha);
        canvas.drawCircle(tip, _mainNodeR * nodeAlpha, nodePaint);

        // Sub-branches
        if (branchProgress >= 1.0) {
          for (final childAngle in b.children) {
            final sa = b.angle + childAngle;
            final subTip = Offset(
              tip.dx + math.cos(sa) * _subLen * maxLen,
              tip.dy + math.sin(sa) * _subLen * maxLen,
            );
            canvas.drawLine(
              tip,
              subTip,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color = b.color.withValues(alpha: 0.35),
            );
            canvas.drawCircle(
              subTip,
              _subNodeR,
              Paint()..color = b.color.withValues(alpha: 0.6),
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BranchPainter old) => old.progress != progress;
}
