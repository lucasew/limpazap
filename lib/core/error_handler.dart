import 'dart:developer';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void reportError(dynamic error, [StackTrace? stackTrace, String? context]) {
    // In a real application, this would integrate with Sentry or another crash reporting tool.
    // For now, we log the error securely and consistently.
    if (kDebugMode) {
      log('================ ERROR ================');
      if (context != null) {
        log('Context: $context');
      }
      log('Error: $error');
      if (stackTrace != null) {
        log('StackTrace: $stackTrace');
      }
      log('=======================================');
    }
  }
}
