/// Master barrel export for JusLegal core.
///
/// Consolidated config/constants live in `config/app_config.dart`
/// (with theme, animations and document templates as part files).
/// Import this single file instead of individual core paths:
///
/// ```dart
/// import 'package:juslegal/core.dart';
/// ```

// Unified configuration, constants, strings, theme, animations and templates.
export 'core/config/app_config.dart';

// Exceptions
export 'core/exceptions/ai_exceptions.dart';

// Router
export 'core/router/app_router.dart';

// Services
export 'core/services/analytics_service.dart';

// Utils
export 'core/utils/logger.dart';
export 'core/utils/password_validator.dart';
export 'core/utils/rate_limiter.dart';
export 'core/utils/text_utils.dart';

// Categories (retained as its own module; referenced by AI prompts)
export 'core/constants/categories.dart';
export 'core/constants/firebase_options.dart';
