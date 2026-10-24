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
- **render-markdown.nvim** — Render Markdown in Neovim buffers

### Navigation
- **telescope.nvim** — Fuzzy finder (files, grep, buffers, git)
- **oil.nvim** — File explorer as an editable buffer (replaces netrw), with a floating window mode

### Editor
- **nvim-treesitter** — Syntax highlighting and indentation
- **nvim-autopairs** — Auto close brackets and quotes
- **toggleterm.nvim** — Floating terminal (`<leader>ot`)
- **undotree** — Visual undo history (`<leader>u`)
- **conform.nvim** — Format Python with Ruff on save
- **nvim-lint** — Lint Python with Flake8

### LSP
- **nvim-lspconfig** + **mason.nvim** — LSP management; Mason installs Pyright, Bash Language Server, Lua Language Server, and Clangd on supported platforms
- **nvim-cmp** — Autocompletion with LuaSnip snippets
- **asm-lsp** — Assembly instruction completion, hover documentation, and operand signature help; enabled when installed on `PATH`

### Debugging
- **MIVN ASM debugger** — Debug native Mach-O binaries with LLDB-DAP on macOS and ELF binaries with GDB on Linux

For Assembly files, completion appears while typing or can be opened with `<C-Space>`. Use `K` over an instruction for its documentation and `<C-k>` in insert mode for operand signature help. Assembly indentation keeps labels and directives at column zero and indents instructions beneath labels by four spaces. `asm-lsp` defaults to x86/x86-64; set the architecture and assembler for a project in its `.asm-lsp.toml` file when using another target. For example, ARM64 GAS projects can use:

```toml
[default_config]
assembler = "gas"
instruction_set = "arm64"
```

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
| Keybind      | Action             |
|--------------|--------------------|
| `<leader>wv` | Split vertical     |
| `<leader>ws` | Split horizontal   |
| `<leader>wq` | Close window       |
| `<leader>ww` | Save               |
| `<leader>we` | Equalize windows   |
| `<leader>w+` | Increase height    |
| `<leader>w-` | Decrease height    |
| `<leader>w>` | Increase width     |
| `<leader>w<` | Decrease width     |
| `<leader>wh` | Focus window left  |
| `<leader>wj` | Focus window down  |
| `<leader>wk` | Focus window up    |
| `<leader>wl` | Focus window right |
| `<leader>wH` | Move window left   |
| `<leader>wJ` | Move window down   |
| `<leader>wK` | Move window up     |
| `<leader>wL` | Move window right  |

### Git
| Keybind      | Action       |
|--------------|--------------|
| `<leader>gs` | Git status   |
| `<leader>gc` | Git commits  |
| `<leader>gb` | Git branches |

### Open
| Keybind      | Action                        |
|--------------|--------------------------------|
| `<leader>ot` | Toggle floating terminal       |
| `<leader>oe` | File explorer (Oil)            |
| `<leader>of` | File explorer, floating (Oil)  |
| `<leader>ol` | Lazy                           |
| `<leader>oc` | Edit Neovim config              |

### Tab
| Keybind      | Action        |
|--------------|---------------|
| `<leader>to` | New tab       |
| `<leader>tc` | Close tab     |
| `<leader>tn` | Next tab      |
| `<leader>tp` | Previous tab  |
| `<leader>tf` | First tab     |
| `<leader>tl` | Last tab      |
| `<leader>tm` | Move tab      |

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
| Keybind      | Action                |
|--------------|------------------------|
| `<leader>u`  | Toggle undotree        |
| `<leader>q`  | Quit all               |
| `<leader>=`  | Format file            |
| `<leader>ad` | Pick an executable in the current directory for ASM debugging |
| `I` (ASM debugger) | Open the program input prompt manually |
| `K` (ASM)    | Show instruction documentation |
| `<C-k>` (ASM, insert mode) | Show operand signature help |
| `<C-\>`      | Dismiss notifications  |

The ASM debugger keeps its program terminal hidden until it detects a read from stdin. When the input window appears, type a line and press `<Enter>`; the window closes and execution resumes. Program output from the hidden terminal is copied into the **PROGRAM OUTPUT** panel. Press `I` in a debugger panel to open the input terminal manually.

Input detection covers `read` and `readv` system calls with file descriptor 0 in GDB, common `read` functions in LLDB, and source-mapped `svc`/`syscall` instructions in LLDB.

### Snippets

Type a trigger in insert mode and press `<Tab>` to expand it. Within a snippet, `<Tab>` moves to the next field and `<S-Tab>` moves to the previous field. Press `<leader>n` to open the WhichKey snippet groups and expand one directly; choose Assembly, Python, or C.

| Language | Triggers |
|----------|----------|
| Assembly | `main`, `func`, `rodata` |
| Python   | `main`, `def`, `class`, `for` |
| C        | `main`, `func`, `for` |

## Structure

```
~/.config/nvim/
├── README.md
├── after/
│   └── ftplugin/
│       └── asm.lua
├── init.lua
├── install.ps1
├── install.sh
├── lua/
│   ├── asm_debug/
│   │   └── init.lua
│   ├── asm_indent.lua
│   ├── autocmd/
│   │   ├── autosave.lua
│   │   └── cursor.lua
│   ├── plugins/
│   │   ├── asm-debug.lua
│   │   ├── auto-session.lua
│   │   ├── autopairs.lua
│   │   ├── catppuccin.lua
│   │   ├── conform.lua
│   │   ├── dashboard.lua
│   │   ├── hlchunk.lua
│   │   ├── lsp.lua
│   │   ├── noice.lua
│   │   ├── nvim-lint.lua
│   │   ├── oil.lua
│   │   ├── render-markdown.lua
│   │   ├── telescope.lua
│   │   ├── toggleterm.lua
│   │   ├── treesitter.lua
│   │   ├── whichkey.lua
│   │   └── undotree.lua
│   ├── snippets/
│   │   ├── asm.lua
│   │   ├── c.lua
│   │   ├── init.lua
│   │   └── python.lua
│   ├── statuscolumn.lua
│   ├── statusline.lua
│   └── tabline.lua
└── tools/
    └── gdb-dashboard.gdbinit
```

## Requirements

- Neovim >= 0.11.0 (the LSP setup uses Neovim's `vim.lsp.config()` API)
- [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped)
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep
- **clangd**: auto-installed by Mason on most platforms (macOS Intel/ARM, Linux x86_64, Windows). On **Linux aarch64** (e.g. Fedora ARM), Mason has no precompiled binary for this architecture — the config detects this automatically and skips it, but you'll need to install it yourself via your package manager (e.g. `sudo dnf install clang-tools-extra` on Fedora) before opening a C/C++ file. Everything else installs and works normally.
- **asm-lsp**: install with `brew install asm-lsp` on macOS, or `cargo install asm-lsp` on other platforms. Neovim enables it when the `asm-lsp` executable is available on `PATH`. Its default instruction set is x86/x86-64. Set `instruction_set` and `assembler` in a project `.asm-lsp.toml` for ARM64 or other Assembly targets.
- **Python formatting and linting**: install Ruff and Flake8 and make both available on `PATH`.

## Installation

### Option 1 — git clone

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
