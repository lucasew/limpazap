## 2024-07-26 - Refactor duplicated logic in AppBar actions

**Issue:** In `ArquivosView.dart`, the `onPressed` callbacks for multiple `IconButton` widgets in the `AppBar` contained duplicated logic. Each would call `setState` to toggle a boolean flag and then immediately call an `update()` method to refresh the UI.

**Root Cause:** The logic was implemented inline for each button, leading to code redundancy. This makes the code harder to read and maintain, as any change to the update mechanism would need to be applied in multiple places.

**Solution:** I introduced a private helper method, `_toggleState(void Function() stateChange)`. This method encapsulates the pattern of calling `setState` with a given state modification function and then calling `loadArquivos()` (which was renamed from `update()` for clarity). The `onPressed` callbacks were then simplified to a single call to this new helper method, passing their specific state change as a lambda function.

**Pattern:** When a Flutter `StatefulWidget` contains multiple event handlers that perform a similar sequence of actions (e.g., updating state and then triggering a UI refresh), extract that sequence into a single, reusable private method. This reduces code duplication, improves readability, and centralizes the logic, making future modifications easier and less error-prone.