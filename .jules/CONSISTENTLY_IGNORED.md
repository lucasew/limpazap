# Consistently Ignored Changes

This file lists patterns of changes that have been consistently rejected by human reviewers. All agents MUST consult this file before proposing a new change. If a planned change matches any pattern described below, it MUST be abandoned.

---

## IGNORE: Adding Confirmation Dialogs for Deletion

**- Pattern:** Do not add a confirmation dialog (e.g., `AlertDialog`) before performing a file deletion or other destructive action.
**- Justification:** This change was proposed in PR #69 and rejected. The project prioritizes a streamlined and fast user experience, and mandatory confirmation steps are considered disruptive to the user flow. Changes that add friction to core actions will be rejected.
**- Files Affected:** `lib/view/arquivo_deletavel_view.dart`
