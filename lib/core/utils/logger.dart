import 'package:flutter/foundation.dart';

/// Log level enumeration
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3);

  final int priority;
  const LogLevel(this.priority);
}

/// SecurityAudit: Structured logger for application-wide logging.
/// Replaces print() statements with categorized, levels-based logging.
/// Supports both console output and external logging services (Crashlytics, etc).
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  static const String _defaultTag = 'JusLegal';
  LogLevel _minLogLevel = LogLevel.debug;
  final List<LogSink> _sinks = [];

  /// Sets minimum log level for console output
  void setLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Adds a log sink (e.g., Crashlytics, file, network)
  void addSink(LogSink sink) {
    _sinks.add(sink);
  }

  /// Log debug message
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging implementation
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final effectiveTag = tag ?? _defaultTag;

    // Console output
    if (level.priority >= _minLogLevel.priority) {
      _logToConsole(level, effectiveTag, message, error, stackTrace);
    }

    // External sinks (Crashlytics, etc)
    for (final sink in _sinks) {
      sink.log(
        level: level,
        tag: effectiveTag,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs to console/debugPrint
  void _logToConsole(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();

    if (kDebugMode) {
      debugPrint('[$timestamp] [$levelString] [$tag] $message');

      if (error != null) {
        debugPrint('Error: $error');
      }

      if (stackTrace != null && kDebugMode) {
        debugPrint('StackTrace:\n$stackTrace');
      }
    }
  }
}

/// Contract for log sinks (Crashlytics, Firebase, file logging, etc)
abstract class LogSink {
  void log({
    required LogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  });

  Future<void> flush();
}

/// Crashlytics integration sink
class CrashlyticsSink implements LogSink {
  @override
  void log({
    required LogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // TODO: Integrate with Firebase Crashlytics
    // FirebaseCrashlytics.instance.log('[$tag] $message');
    // if (error != null) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }

  @override
  Future<void> flush() async {
    // TODO: Implement flush if needed
  }
}

/// Analytics event sink for telemetry
class AnalyticsSink implements LogSink {
  @override
  void log({
    required LogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Only log errors to analytics
    if (level == LogLevel.error) {
      // TODO: Send to analytics service
      // FirebaseAnalytics.instance.logEvent(
      //   name: 'app_error',
      //   parameters: {
      //     'error_tag': tag,
      //     'error_message': message,
      //   },
      // );
    }
  }

  @override
  Future<void> flush() async {
    // TODO: Implement flush if needed
  }
}

/// Convenience getter for logger instance
AppLogger get logger => AppLogger();

/// Convenience functions to replace print() calls
void logDebug(String message, {String? tag}) => logger.debug(message, tag: tag);
void logInfo(String message, {String? tag}) => logger.info(message, tag: tag);
void logWarning(String message, {String? tag}) => logger.warning(message, tag: tag);
void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
    logger.error(message, tag: tag, error: error, stackTrace: stackTrace);
