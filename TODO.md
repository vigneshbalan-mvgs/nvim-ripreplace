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
- [x] **Different Backends**:
    - [x] Offer `git grep` as an alternative search backend.