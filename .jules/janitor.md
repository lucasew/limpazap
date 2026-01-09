## 2026-01-09 - Refactor large method into smaller helpers
**Issue:** The `getArquivos` method in `ArquivoDeletavelController` was a single, monolithic function handling file discovery, mapping, filtering, and sorting. This mixed multiple concerns, making the code difficult to read and maintain.
**Root Cause:** The logic was implemented as a single procedural block, likely for initial simplicity, but it didn't scale well and violated the single-responsibility principle.
**Solution:** I decomposed the method into three focused, private helper functions: `_getAllFiles`, `_mapAndFilterFiles`, and `_sortFiles`. The main `getArquivos` method now orchestrates these smaller pieces, clarifying the overall logic.
**Pattern:** Monolithic methods that perform a sequence of distinct operations should be broken down into smaller, well-named helper functions. This improves code clarity, simplifies testing, and makes the system easier to reason about.
