# Sentinel's Journal

This journal is for recording CRITICAL security learnings only.

## 2024-08-14 - Incomplete File Discovery Due to Single Storage Assumption

**Vulnerability:** The application was only scanning the primary external storage directory for WhatsApp backups by using `getExternalStorageDirectory()`. On devices with multiple storage volumes (e.g., an SD card), this could result in backup files on other storage locations not being discovered or deleted.
**Learning:** Assuming a single external storage location can lead to incomplete data handling and potential data remnants. For security-sensitive operations like cleaning user data, it's critical to account for all possible file locations.
**Prevention:** Always use `getExternalStorageDirectories()` when an application needs to scan for or manage files that could exist on multiple storage volumes. This ensures a comprehensive search and prevents data from being missed.

## 2024-08-15 - Mitigate TOCTOU Race Condition in File Deletion

**Vulnerability:** A Time-of-check to Time-of-use (TOCTOU) race condition existed in the file deletion process. The application would identify a list of backup files to be deleted, but it would not re-verify the file's identity immediately before the delete operation. This created a small window where a malicious actor could potentially swap a legitimate backup file with a different, more sensitive file, leading to unintentional data destruction.
**Learning:** The state of a file on the filesystem can change between the time it's checked and the time it's used. For security-critical operations like file deletion, it is crucial to minimize this window and re-validate the resource to ensure the operation is performed on the intended target.
**Prevention:** Before performing a destructive file operation, always re-verify the file's identity and state (e.g., by checking its name and existence) immediately before the operation executes. This ensures that the file being acted upon is the same one that was originally validated.
