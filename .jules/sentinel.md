# Sentinel's Journal

This journal is for recording CRITICAL security learnings only.

## 2024-08-14 - Incomplete File Discovery Due to Single Storage Assumption
**Vulnerability:** The application was only scanning the primary external storage directory for WhatsApp backups by using `getExternalStorageDirectory()`. On devices with multiple storage volumes (e.g., an SD card), this could result in backup files on other storage locations not being discovered or deleted.
**Learning:** Assuming a single external storage location can lead to incomplete data handling and potential data remnants. For security-sensitive operations like cleaning user data, it's critical to account for all possible file locations.
**Prevention:** Always use `getExternalStorageDirectories()` when an application needs to scan for or manage files that could exist on multiple storage volumes. This ensures a comprehensive search and prevents data from being missed.

## 2026-01-16 - Denial-of-Service via Synchronous File I/O
**Vulnerability:** The application used `listSync()` to read backup files, which is a synchronous operation. If a user had a large number of backup files, this would block the main UI thread, causing the application to freeze and potentially be terminated by the OS.
**Learning:** Synchronous I/O operations on the main thread are a common cause of performance bottlenecks and can lead to denial-of-service vulnerabilities. Even when wrapped in a `Future`, the synchronous operation itself can still block the event loop.
**Prevention:** Always use asynchronous methods (e.g., `list().toList()`) for file system access to ensure the UI remains responsive. Asynchronous operations should be used for any potentially long-running task.
