# Pending Tasks for nvim-ripreplace

## Critical Issues

- [ ] **Address Regex Mismatch in Replacement:** The most critical issue. `string.gsub` (Lua patterns) is used for replacement, while `ripgrep` (PCRE-like regex) is used for searching. This means regex-based replacements will not work as expected. A proper regex engine for Lua is needed, or a clear documentation of this limitation.

## Improvements

- [ ] **Improve `apply_replace` Efficiency:** The one-by-one replacement in `M.apply_replace` reads and writes entire files for each replacement, which can be inefficient. Consider optimizing file I/O or using Neovim's buffer manipulation APIs.
- [ ] **Enhance Inline Editing Robustness:** The `M.apply_inline_edit` function is susceptible to line number mismatches if the user modifies content in the preview that changes line counts. A more robust approach (e.g., diff-based patching) is needed.
- [ ] **Refactor `ui.lua` Code Duplication:** The `M.open_ui` function has significant code duplication for floating and split windows. This should be refactored for better maintainability.

## Testing

- [ ] **Increase Test Coverage:** The current test suite is very limited. Comprehensive unit and integration tests are needed for:
    -   All UI interactions and keybindings.
    -   `M.apply_replace` (both "all" and "one-by-one" scenarios).
    -   `M.project_search` (visual and normal modes).
    -   `M.live_search`.
    -   `M.apply_inline_edit`.
    -   Error handling.