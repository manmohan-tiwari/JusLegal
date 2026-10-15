// -----------------------------------------------------------------------------
// app_config.animations.dart — Animations (formerly core/constants/app_animations.dart)
// -----------------------------------------------------------------------------
part of 'app_config.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curves
  static const Curve curveIn = Curves.easeInOut;
  static const Curve curveOut = Curves.easeOut;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSharp = Curves.easeInOutCubic;

  // Staggered Animation for Lists
  static Widget staggeredListItem(
    Widget child,
    int index, {
    Duration duration = medium,
    Duration delay = Duration.zero,
  }) {
    return _DelayedEntrance(
      delay: delay + Duration(milliseconds: index * 70),
      duration: duration,
      child: child,
    );
  }

  static Widget fadeSlideIn(
    Widget child, {
    Duration duration = medium,
    Duration delay = Duration.zero,
    Offset beginOffset = const Offset(0, 0.08),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _DelayedEntrance(
      delay: delay,
      duration: duration,
      beginOffset: beginOffset,
      curve: curve,
      child: child,
    );
  }

  static Widget pressScale({
    required Widget child,
    required VoidCallback? onTap,
    BorderRadius? borderRadius,
    double pressedScale = 0.97,
    Color? splashColor,
  }) {
    return _PressScale(
      onTap: onTap,
      borderRadius: borderRadius,
      pressedScale: pressedScale,
      splashColor: splashColor,
      child: child,
    );
  }
}

class _DelayedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;

  const _DelayedEntrance({
    required this.child,
    required this.delay,
    required this.duration,
    this.beginOffset = const Offset(0, 0.16),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<_DelayedEntrance> createState() => _DelayedEntranceState();
}

class _DelayedEntranceState extends State<_DelayedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(curved);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;
  final Color? splashColor;

  const _PressScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    required this.pressedScale,
    required this.splashColor,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: _setPressed,
          borderRadius: widget.borderRadius,
          splashColor: widget.splashColor,
          child: widget.child,
        ),
      ),
    );
  }
}
