import 'dart:async';
import 'package:flutter/foundation.dart';

/// SecurityAudit: Rate limiter for API calls to prevent abuse.
/// Implements throttling and debouncing patterns for different call types.
class RateLimiter {
  final Duration minInterval;
  final int maxCallsPerInterval;

  DateTime? _lastCallTime;
  int _callCount = 0;
  Timer? _resetTimer;

  RateLimiter({
    this.minInterval = const Duration(seconds: 1),
    this.maxCallsPerInterval = 5,
  });

  /// Checks if a call is allowed based on rate limits.
  /// Returns true if call is allowed, false if rate limited.
  bool isCallAllowed() {
    final now = DateTime.now();
    final timeSinceLastCall = _lastCallTime == null
        ? null
        : now.difference(_lastCallTime!);

    // Reset count if interval has passed
    if (timeSinceLastCall != null && timeSinceLastCall > minInterval) {
      _callCount = 0;
      _resetTimer?.cancel();
    }

    // Check if we've exceeded max calls in the interval
    if (_callCount >= maxCallsPerInterval) {
      if (kDebugMode) {
        debugPrint(
            '[RateLimiter] Rate limit exceeded: $_callCount calls in ${minInterval.inSeconds}s');
      }
      return false;
    }

    // Update tracking
    _lastCallTime = now;
    _callCount++;

    // Set reset timer if not already set
    if (_resetTimer == null || !_resetTimer!.isActive) {
      _resetTimer = Timer(minInterval, () {
        _callCount = 0;
        _lastCallTime = null;
      });
    }

    if (kDebugMode) {
      debugPrint('[RateLimiter] Call allowed ($_callCount/$maxCallsPerInterval)');
    }

    return true;
  }

  /// Resets the rate limiter state.
  void reset() {
    _callCount = 0;
    _lastCallTime = null;
    _resetTimer?.cancel();
    if (kDebugMode) {
      debugPrint('[RateLimiter] Rate limiter reset');
    }
  }

  /// Cleans up timers when done using the rate limiter.
  void dispose() {
    _resetTimer?.cancel();
  }
}

/// SecurityAudit: Debouncer for UI operations to prevent rapid repeated calls.
/// Delays execution and cancels pending operations on rapid calls.
class Debouncer {
  final Duration delay;
  Timer? _timer;
  VoidCallback? _lastCallback;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Schedules a callback with debouncing.
  /// If called again before [delay], cancels previous and schedules new.
  void call(VoidCallback callback) {
    _timer?.cancel();
    _lastCallback = callback;

    _timer = Timer(delay, () {
      _lastCallback?.call();
      _timer = null;
      _lastCallback = null;
    });

    if (kDebugMode) {
      debugPrint('[Debouncer] Scheduled callback with ${delay.inMilliseconds}ms delay');
    }
  }

  /// Cancels any pending debounced callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastCallback = null;
    if (kDebugMode) {
      debugPrint('[Debouncer] Pending callback cancelled');
    }
  }

  /// Executes pending callback immediately if any.
  void flush() {
    _timer?.cancel();
    _lastCallback?.call();
    _timer = null;
    _lastCallback = null;
    if (kDebugMode) {
      debugPrint('[Debouncer] Pending callback executed immediately');
    }
  }

  /// Cleans up timers.
  void dispose() {
    cancel();
  }
}

/// SecurityAudit: Throttler for rate-limiting frequent operations.
/// Ensures minimum delay between consecutive operations.
class Throttler {
  final Duration minInterval;
  DateTime? _lastExecutionTime;

  Throttler({this.minInterval = const Duration(seconds: 1)});

  /// Executes callback if minimum interval has passed.
  /// Returns true if executed, false if throttled.
  bool execute(VoidCallback callback) {
    final now = DateTime.now();
    final timeSinceLastExecution = _lastExecutionTime == null
        ? null
        : now.difference(_lastExecutionTime!);

    if (timeSinceLastExecution != null &&
        timeSinceLastExecution < minInterval) {
      if (kDebugMode) {
        debugPrint(
            '[Throttler] Throttled: ${minInterval.inMilliseconds - timeSinceLastExecution.inMilliseconds}ms remaining');
      }
      return false;
    }

    _lastExecutionTime = now;
    callback();

    if (kDebugMode) {
      debugPrint('[Throttler] Execution allowed');
    }

    return true;
  }

  /// Resets throttler state.
  void reset() {
    _lastExecutionTime = null;
    if (kDebugMode) {
      debugPrint('[Throttler] Reset');
    }
  }
}
