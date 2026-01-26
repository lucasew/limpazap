# Janitor's Journal

## 2024-07-26 - Refactor duplicated logic in AppBar actions

**Issue:** In `ArquivosView.dart`, the `onPressed` callbacks for multiple `IconButton` widgets in the `AppBar` contained duplicated logic. Each would call `setState` to toggle a boolean flag and then immediately call an `update()` method to refresh the UI.

**Root Cause:** The logic was implemented inline for each button, leading to code redundancy. This makes the code harder to read and maintain, as any change to the update mechanism would need to be applied in multiple places.

**Solution:** I introduced a private helper method, `_toggleState(void Function() stateChange)`. This method encapsulates the pattern of calling `setState` with a given state modification function and then calling `loadArquivos()` (which was renamed from `update()` for clarity). The `onPressed` callbacks were then simplified to a single call to this new helper method, passing their specific state change as a lambda function.

**Pattern:** When a Flutter `StatefulWidget` contains multiple event handlers that perform a similar sequence of actions (e.g., updating state and then triggering a UI refresh), extract that sequence into a single, reusable private method. This reduces code duplication, improves readability, and centralizes the logic, making future modifications easier and less error-prone.

This journal is for recording CRITICAL, non-routine refactoring learnings only.

## 2024-08-15 - Mitigate UI Freezing with Asynchronous I/O

**Issue:** The application used `listSync()` to find backup files, which is a synchronous I/O operation. This blocks the main UI thread, causing the application to freeze or become unresponsive while scanning for files, especially in directories with many files. This creates a poor user experience and can lead to a client-side Denial of Service (DoS).
**Root Cause:** The original implementation likely prioritized simplicity but did not account for the performance implications of synchronous file operations on mobile devices where the UI thread is critical for a smooth experience.
**Solution:** I refactored the file discovery logic to be fully asynchronous. The `listSync()` call was replaced with `dir.list().toList()`, and `Future.wait()` was used to process multiple directories concurrently. This ensures that the UI thread remains unblocked during file scanning.
**Pattern:** Always prefer asynchronous I/O operations (e.g., `list()`, `readAsString()`) over their synchronous counterparts (`listSync()`, `readAsStringSync()`) in Flutter applications, especially for any operation that might run on the UI thread. Use `Future.wait` to efficiently parallelize multiple asynchronous tasks.

## 2026-01-20 - Async File Metadata Loading

**Issue:** `ArquivoDeletavel` used a synchronous factory constructor that called `statSync()`. When processing many files, this would block the main thread, potentially causing UI jank.
**Root Cause:** The model initialization was tightly coupled with synchronous I/O.
**Solution:** Refactored `ArquivoDeletavel` to use a private constructor and a static async `load` factory method. Updated `ArquivoDeletavelController` to use `Future.wait` to load metadata for all files in parallel.
**Pattern:** Avoid synchronous I/O (like `statSync`) in data models or loops on the main thread. Use async static factories and `Future.wait` for parallel processing.
