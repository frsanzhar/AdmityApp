import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Draws a smooth curved zigzag connector between lesson nodes on the course
/// path.
///
/// The connector is fully parent-sized — place it in a [SizedBox] whose height
/// spans the gap between two adjacent EllipseNode3D widgets and whose width
/// matches the lateral offset between them.
///
/// [fromLeft] controls the zigzag direction:
/// - `true`  → path starts on the left side and sweeps to the right.
/// - `false` → path starts on the right side and sweeps to the left.
///
/// An optional shimmer animation (a moving highlight point along the path)
/// plays on repeat when [animate] is `true` AND
/// `MediaQuery.disableAnimations` is false.
class ZigzagConnector extends StatefulWidget {
  const ZigzagConnector({
    super.key,
    this.fromLeft = true,
    this.animate = true,
    this.strokeWidth = 3.5,
    this.color,
    this.dashed = false,
  });

  /// Direction of the zigzag sweep.
  final bool fromLeft;

  /// Whether to run the shimmer motion (gated by reduceMotion).
  final bool animate;

  /// Stroke weight of the connector line.
  final double strokeWidth;

  /// Override line colour.  Defaults to [AppColors.border] (inactive path)
  /// so it stays quiet — callers can pass [AppColors.primary] for an active leg.
  final Color? color;

  /// When true, renders a dashed line instead of a solid one (locked segments).
  final bool dashed;

  @override
  State<ZigzagConnector> createState() => _ZigzagConnectorState();
}

class _ZigzagConnectorState extends State<ZigzagConnector>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shimmer = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStartAnimation();
  }

  @override
  void didUpdateWidget(ZigzagConnector old) {
    super.didUpdateWidget(old);
    _maybeStartAnimation();
  }

  void _maybeStartAnimation() {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.animate && !reduce) {
      if (!_ctrl.isAnimating) {
        // AnimationController.repeat() returns a TickerFuture that completes
        // only when stopped; lifecycle is managed in dispose().
        // ignore: discarded_futures
        _ctrl.repeat();
      }
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = widget.color ?? AppColors.border;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return CustomPaint(
          painter: _ZigzagPainter(
            fromLeft: widget.fromLeft,
            strokeWidth: widget.strokeWidth,
            color: lineColor,
            shimmerT: widget.animate ? _shimmer.value : -1,
            dashed: widget.dashed,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _ZigzagPainter extends CustomPainter {
  const _ZigzagPainter({
    required this.fromLeft,
    required this.strokeWidth,
    required this.color,
    required this.shimmerT,
    required this.dashed,
  });

  final bool fromLeft;
  final double strokeWidth;
  final Color color;
  final double shimmerT; // -1 means no shimmer
  final bool dashed;

  /// Build a smooth cubic Bézier that arcs from one node edge to the other.
  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;

    // Start / end depend on zigzag direction.
    final Offset start;
    final Offset end;
    if (fromLeft) {
      start = Offset(w * 0.25, 0); // upper-centre-left
      end = Offset(w * 0.75, h); // lower-centre-right
    } else {
      start = Offset(w * 0.75, 0);
      end = Offset(w * 0.25, h);
    }

    // Control points create a smooth S-curve.
    final cp1 = Offset(fromLeft ? w * 0.75 : w * 0.25, h * 0.30);
    final cp2 = Offset(fromLeft ? w * 0.25 : w * 0.75, h * 0.70);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    if (dashed) {
      _paintDashed(canvas, path);
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Shimmer: a bright dot travelling along the path.
    if (shimmerT >= 0) {
      _paintShimmer(canvas, path, shimmerT);
    }
  }

  void _paintDashed(Canvas canvas, Path path) {
    // Approximate path length and walk it with a dash pattern.
    const dashLen = 8.0;
    const gapLen = 6.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final segLen = draw ? dashLen : gapLen;
        final next = (distance + segLen).clamp(0, metric.length);
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, next as double),
            Paint()
              ..color = color
              ..strokeWidth = strokeWidth
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round,
          );
        }
        distance = next as double;
        draw = !draw;
      }
    }
  }

  void _paintShimmer(Canvas canvas, Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final tangent = metric.getTangentForOffset(metric.length * t);
    if (tangent == null) return;

    final pt = tangent.position;

    // Glow halo then bright dot.
    canvas
      ..drawCircle(
        pt,
        strokeWidth * 3.5,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(
        pt,
        strokeWidth * 1.4,
        Paint()..color = AppColors.white,
      )
      ..drawCircle(
        pt,
        strokeWidth * 1.4,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_ZigzagPainter old) =>
      old.fromLeft != fromLeft ||
      old.color != color ||
      old.shimmerT != shimmerT ||
      old.dashed != dashed;
}

/// Convenience widget that sizes and places the [ZigzagConnector] between
/// two nodes in a vertical column context.
///
/// [height] is the vertical gap between two adjacent nodes.
/// [lateralOffset] is the absolute horizontal displacement between nodes
/// (half the zigzag width); typically 60–100 on a phone screen.
class SizedZigzagConnector extends StatelessWidget {
  const SizedZigzagConnector({
    required this.height,
    super.key,
    this.lateralOffset = 80,
    this.fromLeft = true,
    this.animate = true,
    this.color,
    this.dashed = false,
  });

  final double height;
  final double lateralOffset;
  final bool fromLeft;
  final bool animate;
  final Color? color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      // Width wide enough to contain both node offsets.
      width: lateralOffset * 2 + 80,
      child: ZigzagConnector(
        fromLeft: fromLeft,
        animate: animate,
        color: color,
        dashed: dashed,
      ),
    );
  }
}
