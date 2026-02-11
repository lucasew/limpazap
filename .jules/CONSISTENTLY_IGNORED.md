# Consistently Ignored Changes

This file lists patterns of changes that have been consistently rejected by human reviewers. All agents MUST consult this file before proposing a new change. If a planned change matches any pattern described below, it MUST be abandoned.

---

## IGNORE: Adding Confirmation Dialogs for Deletion

**- Pattern:** Do not add confirmation dialogs or other user interruptions before file deletion actions.
**- Justification:** Pull request #69, which added a confirmation dialog before deletions, was rejected. This indicates a design preference for a streamlined, uninterrupted user flow. While confirmation dialogs can prevent accidental deletions, they are considered an anti-pattern in the context of this specific application.
**- Files Affected:** `lib/view/ArquivosView.dart`

---

## IGNORE: Refactoring Model Initialization to Async (statSync fix)

**- Pattern:** Converting model constructors (like `ArquivoDeletavel`) from synchronous (`statSync`) to asynchronous static factories (`load`, `create`) and updating controllers to use `Future.wait`.
**- Justification:** Multiple PRs (#85-#94) attempting this specific refactor have been consistently rejected. The added complexity and boilerplate of async initialization for this specific model appears unwanted by the maintainers, despite the theoretical benefits.
**- Files Affected:** `lib/model/ArquivoDeletavelModel.dart`, `lib/controller/ArquivoDeletavelController.dart`

---

## IGNORE: Replacing Established CI Workflows

**- Pattern:** Deleting existing GitHub Actions workflows (e.g., `release.yml`) and replacing them with entirely new files (e.g., `autorelease.yml`) or significantly altering the trigger logic.
**- Justification:** PRs #97 and #102 attempted to replace the release workflow and were rejected. Workflows should be incrementally improved or modified in place rather than replaced, to preserve history and specific trigger configurations.
**- Files Affected:** `.github/workflows/*.yml`

---

## IGNORE: Cosmetic Style Changes in Functional PRs

**- Pattern:** Including large-scale cosmetic changes (e.g., changing quotes from double to single, renaming `ctx` to `context`, adding `const` keywords, or excessive vertical formatting expansion) within PRs focused on functional changes or refactoring.
**- Justification:** PRs #96, #97, #99, and #100 contained significant stylistic noise that obscured the actual logic changes and were rejected. Style enforcement should be handled by automated tools (like `dart format`) in dedicated PRs, not mixed with manual refactoring.
**- Files Affected:** `lib/**/*`
