# TODO for new version

## Core Features

- [x] **Fast, Project-Wide Search**: Leverage `ripgrep` for quick searches, respecting `.gitignore`.
- [x] **Interactive UI**: Implement a floating or split-window interface for displaying results.
- [x] **Live Preview**: Update search results in real-time as the user types.
- [x] **Search and Replace**:
    - [x] Inline editing of results in the preview window.
    - [x] Multi-file search and replace operations.
    - [x] Confirmation for each replacement (y/n/a/q).
- [x] **Regex Support**: Expose `ripgrep`'s regex engine.

## Advanced Features

- [x] **Integration with Neovim's Built-in Components**:
    - [x] Populate search results into the quickfix list.
- [x] **History**: Implement a search history feature.
- [x] **Customization**:
    - [x] Allow user-defined keymaps.
    - [x] Allow UI appearance customization.
    - [x] Allow passing custom flags to `ripgrep`.
- [x] **Contextual Search**:
    - [x] Search within a specific directory.
    - [x] Search within a visual selection.
    - [x] Search within a list of files from other sources (quickfix, buffer list).
    - [x] **Single Unified Modal**: Combine search/replace input and live results into one modal.
- [x] **Different Backends**:
    - [x] Offer `git grep` as an alternative search backend.

## Refactoring

- [x] Refactor `open_ui` function to `lua/ripreplace/ui.lua` to remove duplication and improve modularity.

## Testing

- [x] Create `tests/` directory and a basic test file (`tests/ripreplace_spec.lua`).
- [x] Fix `init.lua` syntax error (missing `end` for `M.show_preview`).
- [x] Fix `ripreplace_spec.lua` syntax error (assertion methods and missing `end)`).
- [x] Fix `ripreplace_spec.lua` `luatest.assert` not found error (removed explicit `require`).

## Bug Fixes / Improvements

- [x] Fixed `E565: Not allowed to change text or change window` error by scheduling UI updates.
- [x] Implemented debouncing for live search in the input modal to improve typing experience.
- [x] Fixed `E5101: Cannot convert given Lua type` error in debouncing by correctly managing timer ID scope.

## Documentation and Project Management

- [ ] `pendingtodo.md`: A dynamic list of pending tasks and identified issues.
- [ ] `rules.md`: Documentation outlining the project's expected behavior and design principles.