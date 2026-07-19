import 'package:flutter/material.dart';

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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Fade Animation
  static Widget fadeIn(
    Widget child, {
    Duration duration = medium,
    Curve curve = curveIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Hero Animation Widget
  static Widget heroWidget(
    String tag,
    Widget child, {
    Duration duration = medium,
    Curve curve = curveIn,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: curve.transform(animation.value),
              child: child,
            );
          },
          child: child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }

  // Pulse Animation
  static Widget pulse(
    Widget child, {
    Duration duration = const Duration(seconds: 1),
    double scale = 1.1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: scale),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce Animation
  static Widget bounce(
    Widget child, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Page Transition Builder
  static PageRouteBuilder<T> slidePageRoute<T>(
    Widget page, {
    Duration duration = medium,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curveOut,
          )),
          child: child,
        );
      },
    );
  }
}

enum SlideDirection { up, down, left, right }
