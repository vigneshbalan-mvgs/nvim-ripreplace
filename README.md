# nvim-ripreplace

A Neovim plugin for project-wide search and replace with an interactive preview.

## ✨ Features

- **Project-wide Search:** Easily search for text across your entire project using `ripgrep`.
- **Interactive Preview:** View search results in a floating window.
- **Visual Selection Search:** Initiate a search directly from a visual selection.
- **Interactive Replacement:**
  - Preview replacements before applying.
  - Replace all occurrences at once.
  - One-by-one replacement with confirmation for each match.

## 🚀 Installation

Install with your favorite plugin manager.

**[packer.nvim](https://github.com/wbthomason/packer.nvim)**

```lua
use 'mvgs/nvim-ripreplace'
```

**[lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
{
  'mvgs/nvim-ripreplace',
  config = function()
    require('ripreplace').setup()
  end
}
```

## 💡 Usage

The plugin provides a single keybinding by default:

- `<leader>rr`: Initiates a project-wide search.
  - If called in **Normal mode**, it will prompt you for a search query.
  - If called in **Visual mode**, it will use the visually selected text as the search query.

Once the search results are displayed in the floating window:

- `q`: Quit the preview window.
- `r`: Prompt to enter a replacement string. After entering, the preview will update to show replacements.
- `a`: Apply all replacements found in the current search.
- `o`: Start one-by-one replacement, prompting for each occurrence.

## ⚙️ Configuration

Currently, there are no configurable options.

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or pull requests.

## 📄 License

This project is licensed under the MIT License.
