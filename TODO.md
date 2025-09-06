# nvim-ripreplace - TODO List

This document outlines known bugs and potential improvements for the `nvim-ripreplace` plugin.

## 🐛 Known Bugs

-   [ ] **Visual mode search not working as expected:**
    -   **Description:** When initiating a search from a visual selection, the `ripgrep` command might not be correctly handling multi-line selections or special characters, leading to no or incorrect results.
    -   **Priority:** High

## ✨ Potential Improvements & New Features

### Core Functionality
-   [ ] **Robust Error Handling:** Implement more comprehensive error handling for `ripgrep` execution (e.g., `rg` not found, `rg` returning errors, invalid search patterns).
-   [ ] **Better Visual Feedback during Replacement:** Provide clearer visual cues in the buffer being modified when performing one-by-one replacements.
-   [ ] **Undo/Redo Functionality:** Add a mechanism to easily undo applied replacements.

### Configuration & Customization
-   [ ] **Custom `ripgrep` Flags:** Allow users to specify custom `ripgrep` flags (e.g., `--case-sensitive`, `--word-regexp`).
-   [ ] **Custom Keymaps:** Provide options to customize the default keybindings.
-   [ ] **Floating Window Appearance:** Allow customization of the floating window's style (e.g., border, colors).

### Search & Filtering
-   [ ] **File Type Filtering:** Add an option to limit searches to specific file types (e.g., only `.lua` files).
-   [ ] **Exclude Files/Directories:** Implement functionality to exclude certain files or directories from the search (e.g., `node_modules`, `.git`).

### Integration
-   [ ] **Integration with Fuzzy Finders:** Explore integration with popular fuzzy finder plugins (e.g., `fzf.vim`, `telescope.nvim`) for search results.
