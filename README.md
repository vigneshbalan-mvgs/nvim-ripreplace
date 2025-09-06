# nvim-ripreplace

A Neovim plugin for project-wide search and replace, inspired by VS Code's search and replace functionality. It uses `ripgrep` for searching and provides an interactive floating window to preview and apply replacements.

![screencast](https://user-images.githubusercontent.com/1157093/209422225-9a551a7c-26a8-4163-80a1-392b71f5182c.gif)

## Features

*   **Project-wide search:** Uses `ripgrep` (`rg`) to search for a pattern in your entire project.
*   **Interactive search modal:** A clean popup to enter search and replace terms.
*   **Live replacement preview:** Shows a live preview of the changes before you apply them.
*   **Multiple replacement options:**
    *   Replace all occurrences at once.
    *   Go through each match and decide whether to replace it or not.
*   **Visual mode support:** Use the text selected in visual mode as your search query.

## Requirements

*   [Neovim](https://neovim.io/) (>= 0.7)
*   [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`)

## Installation

You can install this plugin using your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "mvgs/nvim-ripreplace",
  config = function()
    require("ripreplace").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'mvgs/nvim-ripreplace',
  config = function()
    require'ripreplace'.setup()
  end
}
```

## Usage

The plugin is triggered by pressing `<leader>rr` in either Normal or Visual mode.

### Normal Mode

1.  Press `<leader>rr`.
2.  A modal window will pop up with "Search" and "Replace" fields.
3.  Type your search query. You can also type a replacement term.
4.  Press `<CR>` to initiate the search.
5.  A floating window will appear showing all the matches found by `ripgrep`.
    *   If you provided a replacement term, you will see a preview of the changes.

### Visual Mode

1.  Select some text.
2.  Press `<leader>rr`.
3.  The selected text is used as the search query.
4.  The results window will appear immediately.
5.  Press `r` to enter a replacement term.

### In the Results Window

Once the results are displayed in the floating window, you have several options:

*   `q`: Close the results window.
*   `a`: Apply the replacement to **all** matches.
*   `o`: Go through the matches **one-by-one** and confirm each replacement individually.
*   `e`: (Normal Mode search only) **Edit** the search and replace terms in the initial modal.
*   `r`: (Visual Mode search only) Enter a **replacement** string.

## Configuration

The `setup()` function initializes the default keymaps. You don't need to pass any options for the default behavior.

If you want to set your own keymap instead of the default `<leader>rr`, you can disable the default mapping and create your own.

```lua
require("ripreplace").setup({
  -- The setup function will not create any keymaps by default.
  -- You can set it to true to create the default keymaps.
  create_keymaps = false,
})

-- Example custom keymap
vim.keymap.set({ "n", "v" }, "<leader>fr", require("ripreplace").project_search, { desc = "Find and Replace" })
```
