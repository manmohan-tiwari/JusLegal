/// Compatibility barrel.
///
/// Most of the codebase imports `package:juslegal/core/core.dart`,
/// while the master barrel lives at `lib/core.dart`. This file
/// re-exports it so both import paths resolve to the same exports.

export '../core.dart';
