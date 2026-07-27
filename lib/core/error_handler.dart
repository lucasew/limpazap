import 'dart:developer' as developer;

/// Shared reporting for unexpected failures (scan, delete, UI load).
///
/// Uses [developer.log] in every build mode so release builds are not silent.
/// Call sites already funnel through here; do not add a second facade.
class ErrorHandler {
  ErrorHandler._();

  static void reportError(
    Object? error, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    developer.log(
      error?.toString() ?? 'null',
      name: context ?? 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
