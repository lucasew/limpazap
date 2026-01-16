# Consistently Ignored Changes

This file lists patterns of changes that have been consistently rejected by human reviewers. All agents MUST consult this file before proposing a new change. If a planned change matches any pattern described below, it MUST be abandoned.

---

## IGNORE: Adding Confirmation Dialogs for Deletion

**- Pattern:** Do not add confirmation dialogs or other user interruptions before file deletion actions.
**- Justification:** Pull request #69, which added a confirmation dialog before deletions, was rejected. This indicates a design preference for a streamlined, uninterrupted user flow. While confirmation dialogs can prevent accidental deletions, they are considered an anti-pattern in the context of this specific application.
**- Files Affected:** `lib/view/ArquivosView.dart`

---
