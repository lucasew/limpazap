# Janitor's Journal

This journal is for recording CRITICAL, non-routine refactoring learnings only.

## 2024-08-15 - Mitigate UI Freezing with Asynchronous I/O
**Issue:** The application used `listSync()` to find backup files, which is a synchronous I/O operation. This blocks the main UI thread, causing the application to freeze or become unresponsive while scanning for files, especially in directories with many files. This creates a poor user experience and can lead to a client-side Denial of Service (DoS).
**Root Cause:** The original implementation likely prioritized simplicity but did not account for the performance implications of synchronous file operations on mobile devices where the UI thread is critical for a smooth experience.
**Solution:** I refactored the file discovery logic to be fully asynchronous. The `listSync()` call was replaced with `dir.list().toList()`, and `Future.wait()` was used to process multiple directories concurrently. This ensures that the UI thread remains unblocked during file scanning.
**Pattern:** Always prefer asynchronous I/O operations (e.g., `list()`, `readAsString()`) over their synchronous counterparts (`listSync()`, `readAsStringSync()`) in Flutter applications, especially for any operation that might run on the UI thread. Use `Future.wait` to efficiently parallelize multiple asynchronous tasks.
