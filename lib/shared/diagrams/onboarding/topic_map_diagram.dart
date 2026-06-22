import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Obsidian-style knowledge-graph diagram for onboarding.
///
/// Renders a constellation of colorful nodes connected by thin edges.
/// The [expanded] flag drives the split-apart → reassemble animation.
///
/// Usage:
/// ```dart
/// TopicMapDiagram(expanded: _isExpanded)
/// ```
///
/// Set [expanded] to `true` to scatter nodes outward; `false` to collapse
/// them back to the center cluster. The widget respects
/// `MediaQuery.disableAnimations` — when true, it renders the target
/// state instantly with no transitions.
class TopicMapDiagram extends StatefulWidget {
  const TopicMapDiagram({
    super.key,
    this.expanded = false,
  });

  /// When `true` nodes scatter outward; when `false` they reassemble.
  final bool expanded;

  @override
  State<TopicMapDiagram> createState() => _TopicMapDiagramState();
}

class _TopicMapDiagramState extends State<TopicMapDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  // Node definitions — normalized coordinates (0-1), radius, color.
  static final List<_Node> _nodes = [
    // Hub — center
    const _Node(0.50, 0.50, 18, AppColors.primary),
    // Ring 1
    const _Node(0.50, 0.22, 12, AppColors.accentLime),
    _Node(0.72, 0.34, 10, AppColors.ctaGradient[1]),
    const _Node(0.78, 0.60, 11, AppColors.successGreen),
    const _Node(0.60, 0.78, 9, AppColors.goldKey),
    _Node(0.37, 0.76, 11, AppColors.ctaGradient[2]),
    const _Node(0.24, 0.58, 10, AppColors.errorRed),
    _Node(0.26, 0.34, 9, AppColors.ctaGradient[3]),
    // Ring 2 — outer
    _Node(0.50, 0.07, 7, AppColors.primary.withValues(alpha: 0.55)),
    _Node(0.82, 0.18, 6, AppColors.accentLime.withValues(alpha: 0.55)),
    _Node(0.94, 0.48, 7, AppColors.ctaGradient[1].withValues(alpha: 0.55)),
    _Node(0.86, 0.80, 6, AppColors.successGreen.withValues(alpha: 0.55)),
    _Node(0.63, 0.94, 6, AppColors.goldKey.withValues(alpha: 0.55)),
    _Node(0.34, 0.93, 6, AppColors.ctaGradient[2].withValues(alpha: 0.55)),
    _Node(0.08, 0.74, 7, AppColors.ctaGradient[3].withValues(alpha: 0.55)),
    _Node(0.07, 0.42, 6, AppColors.errorRed.withValues(alpha: 0.55)),
    _Node(0.18, 0.18, 7, AppColors.primary.withValues(alpha: 0.55)),
  ];

  // Edge pairs (index pairs into _nodes)
  static const List<List<int>> _edges = [
    [0, 1],
    [0, 2],
    [0, 3],
    [0, 4],
    [0, 5],
    [0, 6],
    [0, 7],
    [1, 8],
    [1, 9],
    [2, 9],
    [2, 10],
    [3, 10],
    [3, 11],
    [4, 11],
    [4, 12],
    [5, 12],
    [5, 13],
    [6, 13],
    [6, 14],
    [7, 14],
    [7, 15],
    [1, 16],
    [7, 16],
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutCubic,
    );
    if (widget.expanded) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(TopicMapDiagram old) {
    super.didUpdateWidget(old);
    if (old.expanded == widget.expanded) return;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnim) {
      _ctrl.value = widget.expanded ? 1.0 : 0.0;
    } else {
      widget.expanded ? unawaited(_ctrl.forward()) : unawaited(_ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => CustomPaint(
        painter: _TopicMapPainter(
          nodes: _nodes,
          edges: _edges,
          progress: _progress.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Node {
  const _Node(this.nx, this.ny, this.radius, this.color);
  final double nx; // normalized x (0-1)
  final double ny; // normalized y (0-1)
  final double radius;
  final Color color;
}

class _TopicMapPainter extends CustomPainter {
  _TopicMapPainter({
    required this.nodes,
    required this.edges,
    required this.progress,
  });

  final List<_Node> nodes;
  final List<List<int>> edges;

  /// 0 = collapsed (cluster at center), 1 = fully expanded.
  final double progress;

  static const double _expandScale = 1.35;

  Offset _nodePos(Size size, _Node n) {
    // Lerp from center (0.5, 0.5) toward natural position as progress→1.
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final tx = size.width * n.nx;
    final ty = size.height * n.ny;
    return Offset(
      cx + (tx - cx) * progress * _expandScale,
      cy + (ty - cy) * progress * _expandScale,
    ).clamp(Offset.zero, Offset(size.width, size.height));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.border.withValues(alpha: 0.6 + 0.4 * progress);

    // Draw edges first
    for (final e in edges) {
      final a = _nodePos(size, nodes[e[0]]);
      final b = _nodePos(size, nodes[e[1]]);
      canvas.drawLine(a, b, edgePaint);
    }

    // Draw nodes
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final pos = _nodePos(size, n);
      final r = n.radius * (0.5 + 0.5 * progress);

      // Soft glow
      final glowPaint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = n.color.withValues(alpha: 0.25 * progress);
      canvas.drawCircle(pos, r * 1.8, glowPaint);

      // Fill
      final fillPaint = Paint()..color = n.color;
      canvas.drawCircle(pos, r, fillPaint);

      // White inner dot for hub
      if (i == 0) {
        canvas.drawCircle(pos, r * 0.35, Paint()..color = AppColors.white);
      }
    }
  }

  @override
  bool shouldRepaint(_TopicMapPainter old) => old.progress != progress;
}

extension on Offset {
  Offset clamp(Offset min, Offset max) => Offset(
    dx.clamp(min.dx, max.dx),
    dy.clamp(min.dy, max.dy),
  );
}
