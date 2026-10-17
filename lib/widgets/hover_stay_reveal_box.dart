import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An interactive wrapper that hides secondary description text by default
/// to keep UI cards clean and minimal, and smoothly reveals content:
/// - On Desktop/Web: When mouse hovers over the card.
/// - On Mobile/Touch: When the user touches and stays (>220ms) or taps to inspect.
class HoverStayRevealBox extends StatefulWidget {
  final Widget Function(BuildContext context, bool isRevealed) builder;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Duration stayDuration;
  final Duration autoCollapseDuration;
  final bool enableHover;
  final bool enableTouchStay;
  final HitTestBehavior behavior;

  const HoverStayRevealBox({
    super.key,
    required this.builder,
    this.onTap,
    this.borderRadius,
    this.stayDuration = const Duration(milliseconds: 220),
    this.autoCollapseDuration = const Duration(seconds: 6),
    this.enableHover = true,
    this.enableTouchStay = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<HoverStayRevealBox> createState() => _HoverStayRevealBoxState();
}

class _HoverStayRevealBoxState extends State<HoverStayRevealBox> {
  bool _isHovered = false;
  bool _isTouchStayed = false;
  Timer? _stayTimer;
  Timer? _autoCollapseTimer;
  Offset? _downPosition;

  bool get isRevealed => _isHovered || _isTouchStayed;

  @override
  void dispose() {
    _stayTimer?.cancel();
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enableTouchStay) return;
    if (event.kind == PointerDeviceKind.mouse) return;

    _downPosition = event.position;
    _stayTimer?.cancel();
    _autoCollapseTimer?.cancel();

    _stayTimer = Timer(widget.stayDuration, () {
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _isTouchStayed = true;
      });
      _startAutoCollapse();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_downPosition == null) return;
    final distance = (event.position - _downPosition!).distance;
    if (distance > 12) {
      // User is scrolling, cancel stay timer
      _stayTimer?.cancel();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _stayTimer?.cancel();
    _downPosition = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _stayTimer?.cancel();
    _downPosition = null;
  }

  void _startAutoCollapse() {
    _autoCollapseTimer?.cancel();
    _autoCollapseTimer = Timer(widget.autoCollapseDuration, () {
      if (mounted && _isTouchStayed) {
        setState(() {
          _isTouchStayed = false;
        });
      }
    });
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Toggle reveal state for cards without separate tap actions
      setState(() {
        _isTouchStayed = !_isTouchStayed;
      });
      if (_isTouchStayed) {
        _startAutoCollapse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.builder(context, isRevealed);

    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: widget.borderRadius,
          child: content,
        ),
      );
    } else {
      content = GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.translucent,
        child: content,
      );
    }

    if (widget.enableHover) {
      content = MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) {
          if (!_isHovered) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (_isHovered) {
            setState(() => _isHovered = false);
          }
        },
        child: content,
      );
    }

    if (widget.enableTouchStay) {
      content = Listener(
        behavior: widget.behavior,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: content,
      );
    }

    return content;
  }
}

/// Smooth expanding container that slides and fades in when [isRevealed] is true.
class HoverRevealContent extends StatelessWidget {
  final bool isRevealed;
  final Widget child;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const HoverRevealContent({
    super.key,
    required this.isRevealed,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.padding,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      alignment: alignment,
      clipBehavior: Clip.hardEdge,
      child: isRevealed
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: AnimatedOpacity(
                duration: Duration(
                  milliseconds: (duration.inMilliseconds * 0.85).round(),
                ),
                curve: Curves.easeOut,
                opacity: isRevealed ? 1.0 : 0.0,
                child: child,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
