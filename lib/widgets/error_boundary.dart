import 'package:flutter/material.dart';
import '../core/config/theme_config.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object, StackTrace?)? onError;
  final Widget Function()? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.onRetry,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.onError?.call(_error!, _stackTrace) ??
        _buildErrorUI(context);
    }
    
    return widget.child;
  }

  Widget _buildErrorUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.onRetry!(),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

