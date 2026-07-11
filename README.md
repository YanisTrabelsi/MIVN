# MIVN — Neovim Config

A minimal, aesthetic Neovim configuration built around a dark purple/green color palette.

## Color Palette

| Role      | Hex       | Usage                              |
|-----------|-----------|------------------------------------|
| Primary   | `#CBA6F7` | Borders, icons, highlights         |
| Secondary | `#A6F7B2` | Search, keybinds, active elements  |

## Plugins

### UI
- **catppuccin** — Colorscheme (mocha, transparent background)
- **dashboard-nvim** — Start screen with ASCII header
- **noice.nvim** — Floating cmdline (bottom-centered) and notifications
- **nvim-notify** — Persistent notifications (dismiss with `<C-\>`)
- **which-key.nvim** — Keybind popup on leader
- **hlchunk.nvim** — Indent guides and chunk highlighting

### Navigation
- **telescope.nvim** — Fuzzy finder (files, grep, buffers, git)

### Editor
- **nvim-treesitter** — Syntax highlighting and indentation
- **nvim-autopairs** — Auto close brackets and quotes
- **toggleterm.nvim** — Floating terminal (`<leader>t`)
- **undotree** — Visual undo history (`<leader>u`)

### LSP
- **nvim-lspconfig** + **mason.nvim** — LSP management (clangd enabled by default)
- **nvim-cmp** — Autocompletion with LuaSnip snippets

### Session
- **auto-session** — Automatic session save/restore per directory

## Keybinds

Leader key: `<Space>`

### Find
| Keybind            | Action       |
|--------------------|--------------|
| `<leader><leader>` | Find files   |
| `<leader>ff`       | Find files   |
| `<leader>fg`       | Live grep    |
| `<leader>fb`       | Buffers      |
| `<leader>fr`       | Recent files |
| `<leader>fh`       | Help tags    |

### Buffer
| Keybind      | Action          |
|--------------|-----------------|
| `<leader>bd` | Delete buffer   |
| `<leader>bn` | Next buffer     |
| `<leader>bp` | Previous buffer |

### Window
| Keybind      | Action           |
|--------------|------------------|
| `<leader>wv` | Split vertical   |
| `<leader>ws` | Split horizontal |
| `<leader>wq` | Close window     |
| `<leader>ww` | Save             |
| `<leader>wh` | Move left        |
| `<leader>wj` | Move down        |
| `<leader>wk` | Move up          |
| `<leader>wl` | Move right       |

### Git
| Keybind      | Action       |
|--------------|--------------|
| `<leader>gs` | Git status   |
| `<leader>gc` | Git commits  |
| `<leader>gb` | Git branches |

### Session
| Keybind      | Action               |
|--------------|----------------------|
| `<leader>ss` | Save session         |
| `<leader>sr` | Restore session      |
| `<leader>se` | Enable auto-session  |
| `<leader>sd` | Disable auto-session |
| `<leader>sD` | Delete session       |
| `<leader>st` | Toggle auto-session  |

### Misc
| Keybind      | Action                   |
|--------------|--------------------------|
| `<leader>t`  | Toggle floating terminal |
| `<leader>u`  | Toggle undotree          |
| `<leader>q`  | Quit all                 |
| `<leader>=`  | Format file              |
| `<C-\>`      | Dismiss notifications    |

## Structure

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── autocmd/
    │   ├── autosave.lua
    │   └── cursor.lua
    ├── plugins/
    │   ├── catppuccin.lua
    │   ├── dashboard.lua
    │   ├── noice.lua
    │   ├── telescope.lua
    │   ├── toggleterm.lua
    │   ├── treesitter.lua
    │   ├── whichkey.lua
    │   ├── lsp.lua
    │   ├── autopairs.lua
    │   ├── auto-session.lua
    │   ├── hlchunk.lua
    │   └── undotree.lua
    ├── statuscolumn.lua
    └── statusline.lua
```

## Requirements

- Neovim >= 0.9.0
- [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped)
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep
- **clangd**: auto-installed by Mason on most platforms (macOS Intel/ARM, Linux x86_64, Windows). On **Linux aarch64** (e.g. Fedora ARM), Mason has no precompiled binary for this architecture — the config detects this automatically and skips it, but you'll need to install it yourself via your package manager (e.g. `sudo dnf install clang-tools-extra` on Fedora) before opening a C/C++ file. Everything else installs and works normally.

## Installation

### Option 1 — git clone (recommended)

```bash
git clone git@github.com:YanisTrabelsi/MIVN.git ~/.config/nvim
nvim
```

### Option 2 — curl

If you don't have SSH keys set up, run the install script — it downloads the latest snapshot and backs up any existing config automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/YanisTrabelsi/MIVN/main/install.sh | bash
nvim
```

### Option 3 — Windows (PowerShell)

`install.sh` is a bash script and won't run in `cmd`/PowerShell directly. Two options:

**a) WSL / Git Bash** — behaves like Linux/macOS, use Option 1 or 2 above (config goes to `~/.config/nvim`).

**b) Native Windows** — use the PowerShell script instead (config goes to `%LOCALAPPDATA%\nvim`):

```powershell
irm https://raw.githubusercontent.com/YanisTrabelsi/MIVN/main/install.ps1 | iex
nvim
```

> If PowerShell blocks the script, run once: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## Requirements (Windows)

Same as above, plus:
- A terminal that renders true color and Nerd Font glyphs correctly (Windows Terminal recommended)
- ripgrep via `winget install BurntSushi.ripgrep.MSVC` or `scoop install ripgrep`

Lazy.nvim will automatically install all plugins on first launch.
