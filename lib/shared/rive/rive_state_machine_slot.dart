import 'dart:async';

import 'package:admity/shared/rive/rive_loader.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// A generic Rive State Machine slot.
///
/// Loads [assetPath], instantiates a [RiveWidgetController] for [machineName],
/// and calls [onController] so the caller can grab inputs/triggers from app
/// state.
///
/// ### reduceMotion
/// When `MediaQuery.of(context).disableAnimations` is true the widget renders
/// [staticFallback] immediately (no Rive load attempted).
///
/// ### Missing asset
/// If the .riv file hasn't been delivered yet the widget renders
/// [staticFallback] silently (no exception).
///
/// ### Layout contract
/// Sizes itself to [width] x [height].  When either is null, the slot is
/// unconstrained on that axis — the caller must ensure a bounded parent box.
class RiveStateMachineSlot extends StatefulWidget {
  const RiveStateMachineSlot({
    required this.assetPath,
    required this.machineName,
    required this.staticFallback,
    super.key,
    this.onController,
    this.width,
    this.height,
    this.fit = Fit.contain,
    this.alignment = Alignment.center,
  });

  /// Path in the asset bundle, e.g. `'assets/rive/mascot.riv'`.
  final String assetPath;

  /// Rive State Machine name inside the .riv file.
  final String machineName;

  /// Rendered when the asset is absent OR `disableAnimations` is true.
  final Widget staticFallback;

  /// Called once the [RiveWidgetController] is ready.
  /// Use this to grab inputs/triggers and drive them from app state.
  final void Function(RiveWidgetController controller)? onController;

  final double? width;
  final double? height;
  final Fit fit;
  final Alignment alignment;

  @override
  State<RiveStateMachineSlot> createState() => _RiveStateMachineSlotState();
}

class _RiveStateMachineSlotState extends State<RiveStateMachineSlot> {
  RiveWidgetController? _controller;
  bool _loaded = false;
  bool _assetFound = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      unawaited(_loadAsset());
    }
  }

  Future<void> _loadAsset() async {
    final file = await loadRiveAsset(widget.assetPath);
    if (!mounted) return;
    if (file == null) {
      setState(() => _assetFound = false);
      return;
    }

    RiveWidgetController? ctrl;
    try {
      ctrl = RiveWidgetController(
        file,
        stateMachineSelector: StateMachineNamed(widget.machineName),
      );
      // ignore: avoid_catches_without_on_clauses // Must catch Error + Exception from Rive internals.
    } catch (_) {
      // State machine not found in file, or native renderer unavailable.
      setState(() => _assetFound = false);
      return;
    }

    if (!mounted) {
      ctrl.dispose();
      return;
    }

    setState(() => _controller = ctrl);
    widget.onController?.call(ctrl);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Reduce-motion, missing asset, or still loading — static fallback.
    // The fallback is NOT wrapped in the slot's width/height constraints so
    // that a SizedBox.shrink() fallback truly takes zero space and does not
    // displace surrounding widgets.
    if (reduceMotion || !_assetFound || _controller == null) {
      return widget.staticFallback;
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RiveWidget(
        controller: _controller!,
        fit: widget.fit,
        alignment: widget.alignment,
      ),
    );
  }
}
