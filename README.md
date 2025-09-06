# nvim-ripreplace

A Neovim plugin for project-wide search and replace, inspired by VS Code's search and replace functionality. It uses `ripgrep` for searching and provides an interactive floating window to preview and apply replacements.

## Features

*   **Project-wide search:** Uses `ripgrep` (`rg`) to search for a pattern in your entire project.
*   **Interactive floating window:** Displays search results in a clean, interactive floating window.
*   **Live replacement preview:** Shows a live preview of the changes before you apply them.
*   **Multiple replacement options:**
    *   Replace all occurrences at once.
    *   Go through each match and decide whether to replace it or not.
*   **Visual mode support:** Use the text selected in visual mode as your search query.

## Requirements

*   [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`)

## Installation

You can install this plugin using your favorite plugin manager.

### Packer

```lua
use {
  'mvgs/nvim-ripreplace',
  config = function()
    require'ripreplace'.setup()
  end
}
```

### vim-plug

```vim
Plug 'mvgs/nvim-ripreplace'
```

Then, in your `init.vim` or `init.lua`, you need to call the `setup` function:

```lua
require'ripreplace'.setup()
```

## Usage

1.  Press `<leader>rr` in normal mode or visual mode to start a search.
    *   In normal mode, you will be prompted to enter a search term.
    *   In visual mode, the selected text will be used as the search term.
2.  The search results will be displayed in a floating window.
3.  Inside the floating window, you have the following options:
    *   `r`: Enter a replacement string. The preview will update to show the changes.
    *   `a`: Apply the replacement to all matches.
    *   `o`: Go through the matches one-by-one and confirm each replacement.
    *   `q`: Close the floating window.