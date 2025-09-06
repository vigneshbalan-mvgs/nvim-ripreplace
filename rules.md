# nvim-ripreplace Rules and Design Principles

This document outlines the expected behavior, design principles, and conventions for the `nvim-ripreplace` plugin. Adhering to these rules ensures consistency, maintainability, and a high-quality user experience.

## Core Functionality

1.  **Project-Wide Search:** The plugin must accurately search for patterns across the entire project using `ripgrep` (or `git grep` as an alternative backend).
2.  **Interactive UI:** Provide a clear, intuitive, and interactive user interface for entering search/replace terms and previewing results.
3.  **Live Preview:** Offer a live preview of replacements as the user types, reflecting the changes that will be applied.
4.  **Flexible Replacement:** Support both "replace all" and "one-by-one" replacement options.
5.  **Visual Mode Integration:** Seamlessly integrate with Neovim's visual mode to use selected text as the search query.

## Technical Principles

1.  **Efficiency:** Operations, especially file I/O during replacements, should be as efficient as possible to avoid performance bottlenecks, particularly with large files or numerous replacements.
2.  **Robustness:** The plugin must handle various edge cases gracefully, including:
    *   No matches found.
    *   Empty search/replace terms.
    *   File permission issues.
    *   External tool (ripgrep) not found.
3.  **Modularity:** Code should be organized into logical modules (`init.lua` for core logic, `ui.lua` for UI components) with clear responsibilities.
4.  **Configuration:** Allow users to customize keymaps, UI behavior (float/split), and `ripgrep` flags through a `setup()` function.
5.  **Neovim Idioms:** Utilize Neovim's built-in APIs and conventions where appropriate (e.g., floating windows, keymaps, quickfix list).

## Regex Handling

1.  **Consistent Regex Flavor:** The regex flavor used for searching (by `ripgrep`) and for replacement (by the plugin's internal logic) *must* be consistent. If `ripgrep` uses PCRE-like regex, the replacement mechanism must also support PCRE-like regex. **This is a critical rule.**
2.  **Clear Documentation:** Any limitations regarding regex support (e.g., if only literal string replacement is supported for certain scenarios) must be clearly documented.

## User Experience (UX)

1.  **Minimal Disruption:** The UI should be non-intrusive and easily dismissible.
2.  **Clear Feedback:** Provide clear notifications to the user about search results, replacement status, and any errors.
3.  **History:** Maintain a history of recent search and replace terms for convenience.

## Code Quality

1.  **Readability:** Code should be clean, well-structured, and easy to understand.
2.  **Maintainability:** Avoid code duplication and use clear function names and comments where necessary.
3.  **Testability:** Design components to be easily testable, and maintain a comprehensive test suite to prevent regressions.

## Future Considerations

1.  **Extensibility:** Design the plugin in a way that allows for future enhancements (e.g., support for other search backends, more advanced replacement options).

## Known issues / shortcomings

- Implementation bugs
  - Several functions call get_search_command(...) instead of M.get_search_command(...), which leads to errors at runtime.
  - The live-preview timer uses an inconsistent variable name and doesn't reliably cancel previous timers.
  - Buffer-local keymaps are deleted after M.active_buf is cleared, which prevents proper cleanup.
  - Quickfix and inline-edit routines reference undefined locals (win, buf) and mix module/global state.
- Robustness and safety
  - File operations use plain io.* without consistent error handling or permission checks.
  - Search/replace uses Lua pattern-based gsub in some places which may not match ripgrep's regex flavor (PCRE). Regex parity is not yet guaranteed.
  - Large projects may trigger many file reads/writes without batching or backup/undo considerations.
- UX and consistency
  - Modal cursor placement and key hints can be confusing; history navigation is basic.
  - Error messages are minimal; users may not get clear guidance when ripgrep is missing or when permissions prevent writes.
- Missing features / polish
  - No explicit ripgrep availability check on setup.
  - No unit tests or CI checks to prevent regressions.
  - Limited handling for binary files, symlinks, and .gitignore respect (depends entirely on rg flags).

Recommended quick wins:
1. Replace all get_search_command(...) calls with M.get_search_command(...).
2. Normalize timer usage: keep one timer_id per modal and cancel it before creating a new timer.
3. Delete buffer-local keymaps before clearing M.active_buf and closing the window.
4. Use safer file IO patterns (pcall, check for nil file handles) and consider writing to temp files then moving into place.
5. Add a setup-time check for ripgrep and surface a helpful message if missing.