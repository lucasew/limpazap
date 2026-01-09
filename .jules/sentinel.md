# Sentinel's Journal

This journal is for recording CRITICAL security learnings only.

## 2024-08-14 - Incomplete File Discovery Due to Single Storage Assumption
**Vulnerability:** The application was only scanning the primary external storage directory for WhatsApp backups by using `getExternalStorageDirectory()`. On devices with multiple storage volumes (e.g., an SD card), this could result in backup files on other storage locations not being discovered or deleted.
**Learning:** Assuming a single external storage location can lead to incomplete data handling and potential data remnants. For security-sensitive operations like cleaning user data, it's critical to account for all possible file locations.
**Prevention:** Always use `getExternalStorageDirectories()` when an application needs to scan for or manage files that could exist on multiple storage volumes. This ensures a comprehensive search and prevents data from being missed.


## 2026-01-09 - Insecure Path Construction via String Concatenation
**Vulnerability:** The application constructed file paths by manually concatenating strings. This method is dangerous as it can introduce path traversal vulnerabilities if any part of the path is derived from user input or external sources in the future. It's also less portable across different operating systems.
**Learning:** Manually joining path segments with '/' or '\' is a common source of security flaws and bugs. The logic for handling file system paths is complex and platform-dependent.
**Prevention:** Always use a dedicated path manipulation library, such as Dart's `path` package, to construct file system paths. The `p.join()` function safely handles separators and prevents traversal attacks, leading to more secure and maintainable code.
