/// Shared flutter_animate presets for Admity screens.
///
/// All presets respect `MediaQuery.disableAnimations` — callers should gate on
/// that flag before applying effects that are purely decorative.
///
/// Usage (screen-level entrance):
/// ```dart
/// MyWidget().animate().fadeSlideIn()
/// ```
/// or use [AnimPresetsExt] directly on a widget.
///
/// Durations are tuned to feel Brilliant-grade: subtle, never distracting.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ── Duration constants ────────────────────────────────────────────────────────

/// Standard entrance duration (fade + slide).
const kAnimEntranceDuration = Duration(milliseconds: 350);

/// Standard exit duration.
const kAnimExitDuration = Duration(milliseconds: 220);

/// Short micro-interaction (badge pulse, scale bounce).
const kAnimMicroDuration = Duration(milliseconds: 220);

/// Delay step used for staggered lists (each item offset by this).
const kAnimStaggerStep = Duration(milliseconds: 60);

// ── Curves ────────────────────────────────────────────────────────────────────

/// Standard entrance curve — ease out for a snappy feel.
const Curve kAnimEntranceCurve = Curves.easeOutCubic;

/// Bounce curve for scale micro-interactions.
const Curve kAnimBounceCurve = Curves.easeOutBack;

// ── Extension on AnimateManager ───────────────────────────────────────────────

/// Convenience extension so callers can write:
/// ```dart
/// child.animate().fadeSlideIn()
/// child.animate().fadeSlideIn(delay: 120.ms)
/// ```
extension AnimPresetsExt<T extends AnimateManager<T>> on T {
  /// Fade in + slight upward slide.  Standard screen/card entrance.
  T fadeSlideIn({
    Duration duration = kAnimEntranceDuration,
    Duration delay = Duration.zero,
    Curve curve = kAnimEntranceCurve,
  }) {
    return fade(
      duration: duration,
      delay: delay,
      curve: curve,
    ).slideY(
      // flutter_animate slideY begin/end are fractions of the widget height.
      begin: 0.10,
      end: 0,
      duration: duration,
      delay: delay,
      curve: curve,
    );
  }

  /// Quick scale pop — for badges / count increments.
  T scalePop({
    Duration duration = kAnimMicroDuration,
    Duration delay = Duration.zero,
  }) {
    return scale(
      begin: const Offset(0.82, 0.82),
      end: const Offset(1, 1),
      duration: duration,
      delay: delay,
      curve: kAnimBounceCurve,
    );
  }
}

// ── reduceMotion helper ───────────────────────────────────────────────────────

/// Returns true when the platform has requested reduced motion.
///
/// Widgets should use this to skip purely decorative animations:
/// ```dart
/// if (!reduceMotion(context)) child.animate().fadeSlideIn()
/// else child
/// ```
bool reduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;
