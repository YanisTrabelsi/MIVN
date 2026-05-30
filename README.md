# Neovim Config

A minimal, aesthetic Neovim configuration built around a dark purple/green color palette.

## Color Palette

| Role      | Hex       | Usage                              |
|-----------|-----------|------------------------------------|
| Primary   | `#CBA6F7` | Borders, icons, highlights         |
| Secondary | `#A6F7B2` | Search, keybinds, active elements  |

## Plugins

### UI
- **catppuccin** — Colorscheme (mocha, transparent background)
- **bufferline.nvim** — Tab bar with per-tab buffer isolation
- **noice.nvim** — Floating cmdline and notifications
- **nvim-notify** — Persistent notifications (dismiss with `<C-\>`)
- **which-key.nvim** — Keybind popup

### Navigation
- **telescope.nvim** — Fuzzy finder (files, grep, buffers, git)

### Editor
- **nvim-treesitter** — Syntax highlighting and indentation
- **nvim-autopairs** — Auto close brackets and quotes
- **toggleterm.nvim** — Floating terminal (`<leader>t`)

### LSP
- **nvim-lspconfig** + **mason.nvim** — LSP management
- **nvim-cmp** — Autocompletion with LuaSnip snippets

## Keybinds

Leader key: `<Space>`

| Keybind       | Action               |
|---------------|----------------------|
| `<leader>ff`  | Find files           |
| `<leader>fg`  | Live grep            |
| `<leader>fb`  | Buffers              |
| `<leader>fr`  | Recent files         |
| `<leader>fh`  | Help tags            |
| `<leader>bd`  | Delete buffer        |
| `<leader>bn`  | Next buffer          |
| `<leader>bp`  | Previous buffer      |
| `<leader>wv`  | Split vertical       |
| `<leader>ws`  | Split horizontal     |
| `<leader>wq`  | Close window         |
| `<leader>ww`  | Save                 |
| `<leader>gs`  | Git status           |
| `<leader>gc`  | Git commits          |
| `<leader>gb`  | Git branches         |
| `<leader>e`   | File explorer        |
| `<leader>h`   | Clear highlights     |
| `<leader>q`   | Quit                 |
| `<leader>Q`   | Quit all             |
| `<leader>t`   | Toggle terminal      |
| `<C-\>`       | Dismiss notifications|

## Structure

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── autocmd/
    │   ├── cursor.lua
    │   └── colorScheme.lua
    ├── plugins/
    │   ├── catppuccin.lua
    │   ├── bufferline.lua
    │   ├── noice.lua
    │   ├── telescope.lua
    │   ├── toggleterm.lua
    │   ├── treesitter.lua
    │   ├── whichkey.lua
    │   ├── lsp.lua
    │   └── autopairs.lua
    ├── statuscolumn.lua
    └── statusline.lua
```

## Requirements

- Neovim >= 0.9.0
- [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped)
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep
- [stylua](https://github.com/JohnnyMorganz/StyLua) for Lua formatting (optional)

## Installation

```bash
git clone git@github.com:YanisTrabelsi/MIVN.git ~/.config/nvim
nvim
```

Lazy.nvim will automatically install all plugins on first launch.
