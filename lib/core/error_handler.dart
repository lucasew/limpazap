import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void reportError(dynamic error, [StackTrace? stackTrace, String? context]) {
    // In a real application, this would integrate with Sentry or another crash reporting tool.
    // For now, we log the error securely and consistently.
    if (kDebugMode) {
      debugPrint('================ ERROR ================');
      if (context != null) {
        debugPrint('Context: $context');
      }
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      debugPrint('=======================================');
    }
  }
}
