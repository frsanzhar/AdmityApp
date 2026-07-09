/// Roadmap screen — Duolingo-style vertical zigzag of 12 personality tests.
///
/// Rules:
///   • Test N is available only after completing test N-1.
///   • Completed tests can be retaken (result updates).
///   • The current available test pulses with an active animation.
///   • Future tests show a padlock icon and are not tappable.
library;

import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/psytests/application/psytests_notifier.dart';
import 'package:admity/features/psytests/data/psytests_seed.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Vertical zigzag roadmap of all 12 psych tests.
class PsytestsRoadmapScreen extends ConsumerWidget {
  const PsytestsRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(psytestsProvider);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    if (state.isLoading) {
      return const AppScaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final completedIds =
        state.results.map((r) => r.testId).toSet();
    final completedCount = completedIds.length;
    final total = psytestsDefs.length;

    return AppScaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoadmapHeader(
            completed: completedCount,
            total: total,
            tokens: tokens,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ZigzagPath(
                    defs: psytestsDefs,
                    completedIds: completedIds,
                    results: state.results,
                    tokens: tokens,
                    onTap: (def) => context.push('/psytests/${def.id}'),
                  ),
                  SizedBox(height: tokens.gapXxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _RoadmapHeader extends StatelessWidget {
  const _RoadmapHeader({
    required this.completed,
    required this.total,
    required this.tokens,
  });

  final int completed;
  final int total;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapMd,
        tokens.screenPadding,
        tokens.gapMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Путь тестов',
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: tokens.gapXs),
          Text(
            '$completed из $total тестов пройдено',
            style: textTheme.bodySmall,
          ),
          SizedBox(height: tokens.gapSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zigzag path ────────────────────────────────────────────────────────────────

/// Builds the Duolingo-style zigzag node path.
///
/// Nodes alternate between left, centre, and right columns to create
/// a winding path.  A dashed connector line links adjacent nodes.
class _ZigzagPath extends StatelessWidget {
  const _ZigzagPath({
    required this.defs,
    required this.completedIds,
    required this.results,
    required this.tokens,
    required this.onTap,
  });

  final List<PsyTestDef> defs;
  final Set<String> completedIds;
  final List<PsyTestResult> results;
  final AppTokens tokens;
  final void Function(PsyTestDef def) onTap;

  // Column alignment for index 0..N — repeating zigzag pattern.
  static const _xOffsets = <double>[
    0.15, // left
    0.50, // centre
    0.80, // right
    0.50, // centre
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const double nodeSize = 64;
        const double rowHeight = 96;

        // Total height: N nodes * rowHeight + a bit extra at the bottom.
        final totalHeight = defs.length * rowHeight + nodeSize;

        final children = <Widget>[];

        for (var i = 0; i < defs.length; i++) {
          final def = defs[i];
          final xFraction = _xOffsets[i % _xOffsets.length];
          final xPos = (width - nodeSize) * xFraction;
          final yPos = i * rowHeight;

          // Node state
          final isDone = completedIds.contains(def.id);
          final isActive = !isDone &&
              (i == 0 ||
                  completedIds.contains(defs[i - 1].id));
          final isLocked = !isDone && !isActive;

          final nodeState = isDone
              ? LessonNodeState.done
              : isActive
                  ? LessonNodeState.active
                  : LessonNodeState.locked;

          // Dashed connector to next node.
          if (i < defs.length - 1) {
            final nextXFraction = _xOffsets[(i + 1) % _xOffsets.length];
            final nextXPos = (width - nodeSize) * nextXFraction;
            final nextYPos = (i + 1) * rowHeight;
            children.add(
              Positioned(
                child: CustomPaint(
                  size: Size(width, totalHeight),
                  painter: _ConnectorPainter(
                    from: Offset(xPos + nodeSize / 2, yPos + nodeSize),
                    to: Offset(nextXPos + nodeSize / 2, nextYPos),
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
              ),
            );
          }

          // The node itself.
          children.add(
            Positioned(
              left: xPos,
              top: yPos,
              child: SizedBox(
                width: nodeSize,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LessonNode(
                      state: nodeState,
                      onTap: isLocked ? null : () => onTap(def),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${def.emoji} ${def.order}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppColors.inkSecondary
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Info card for active node.
          if (isActive) {
            final cardLeft = math.max<double>(0, xPos - 80);
            children.add(
              Positioned(
                left: cardLeft,
                right: math.max<double>(0, width - cardLeft - 240),
                top: yPos + nodeSize + 20,
                child: _ActiveNodeCard(def: def, tokens: tokens),
              ),
            );
          }
        }

        return SizedBox(
          height: totalHeight,
          child: Stack(children: children),
        );
      },
    );
  }

}

// ── Active node info card ──────────────────────────────────────────────────────

class _ActiveNodeCard extends StatelessWidget {
  const _ActiveNodeCard({required this.def, required this.tokens});

  final PsyTestDef def;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${def.emoji} ${def.title}',
            style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: tokens.gapXs),
          Text(
            def.description,
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Connector painter ──────────────────────────────────────────────────────────

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.from,
    required this.to,
    required this.color,
  });

  final Offset from;
  final Offset to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashLen = 6.0;
    const gapLen = 4.0;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;

    final ux = dx / dist;
    final uy = dy / dist;

    var drawn = 0.0;
    var onDash = true;
    while (drawn < dist) {
      final segLen =
          math.min(onDash ? dashLen : gapLen, dist - drawn);
      if (onDash) {
        canvas.drawLine(
          Offset(from.dx + ux * drawn, from.dy + uy * drawn),
          Offset(
            from.dx + ux * (drawn + segLen),
            from.dy + uy * (drawn + segLen),
          ),
          paint,
        );
      }
      drawn += segLen;
      onDash = !onDash;
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.from != from || old.to != to || old.color != color;
}
