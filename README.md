# MIVN — Neovim Config

A Neovim configuration with a customizable dashboard, language tools, and assembly debugger.

## Color Palette

| Role      | Hex       | Usage                              |
|-----------|-----------|------------------------------------|
| Primary   | `#CBA6F7` | Borders, icons, highlights (default) |
| Secondary | `#A6F7B2` | Search, keybinds, active elements (default) |
| Text      | `#CDD6F4` | Main UI labels |
| Muted     | `#6C7086` | Secondary labels |
| Surface   | `#313244` | Opaque floating windows |
| Error     | `#F38BA8` | Errors and command status |
| Warning   | `#F9E2AF` | Warnings and changed values |
| Success   | `#A6E3A1` | Success state |
| Info      | `#89B4FA` | Informational labels |
| Visual    | `#FAB387` | Visual mode status |

Edit these roles under `theme.colors` in [lua/mivn/user_config.lua](lua/mivn/user_config.lua). The dashboard title has a slow, soft glow; set `dashboard.animation.enabled = false` to turn it off.

## Plugins

### UI
- **catppuccin** — Colorscheme (mocha, transparent background)
- **dashboard-nvim** — Start screen with ASCII header
- **noice.nvim** — Floating cmdline and popup menu; notifications use Neovim's built-in message display
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
- **Auto-save** — Saves edits after a short delay outside Insert mode and on leaving Insert mode; formatters run only on save

### LSP
- **nvim-lspconfig** + **mason.nvim** — LSP management; Mason installs Pyright, Bash Language Server, Lua Language Server, and Clangd on supported platforms
- **nvim-cmp** — Autocompletion; LuaSnip and Friendly Snippets can be toggled separately
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
- **auto-session** — Automatic session save per directory, with manual restore

### Personalization
- Open **Edit MIVN settings** from the dashboard, press `<leader>os`, or run `:MivnSettings`. It opens [lua/mivn/user_config.lua](lua/mivn/user_config.lua), a normal Lua file with editable values and comments. Save it to reload appearance, dashboard, auto-save, and LSP language enablement. Plugin on/off switches and setup options require restarting Neovim.
- Each entry under `plugins` can be set to `false` to disable that plugin, or `true` to re-enable it. Related settings are grouped under `plugin_options` (Catppuccin, WhichKey, Telescope, Oil, ToggleTerm, Treesitter, completion, formatters, linters, LSP servers, sessions, Noice and more). Plugin options include common settings and an advanced `setup` table for the plugin's native configuration; LSP servers have their own options. The ASM debugger needs Telescope for its executable picker, so it is automatically disabled while Telescope is off. Set `theme.transparent_floats` or `theme.transparent_background` to `false` only if you want opaque windows; both are transparent by default. Neovim's native notifications remain enabled by default.

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
| `<leader>gf`       | Git files    |
| `<leader>gs`       | Git status   |
| `<leader>gc`       | Git commits  |

### Buffer
| Keybind      | Action          |
|--------------|-----------------|
| `<leader>bd` | Delete buffer   |
| `<leader>bn` | Next buffer     |
| `<leader>bp` | Previous buffer |

### Language tools

| Keybind | Action |
|---------|--------|
| `<leader>lg` | Go to definition |
| `<leader>lR` | Find references |
| `<leader>li` | Go to implementation |
| `<leader>lt` | Go to type definition |
| `<leader>lh` | Show hover documentation |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code action |
| `<leader>ld` | List diagnostics |
| `<leader>lf` | Format buffer |

### Open, tools, and sessions

| Keybind | Action |
|---------|--------|
| `<leader>os` | Edit MIVN settings |
| `<leader>oc` | Edit `init.lua` |
| `<leader>od` | Open dashboard |
| `<leader>of` | Open Oil file explorer |
| `<leader>ot` | Toggle terminal |
| `<leader>ss` | Save session |
| `<leader>sr` | Restore session |
| `<leader>sf` | Find session |
| `<leader>u` | Toggle undo history |
| `<leader>ad` | Pick an executable for the ASM debugger |

Plugin-related mappings appear in WhichKey only while that plugin is enabled; turning off WhichKey itself does not remove the mappings.

### Window
| Keybind      | Action             |
|--------------|--------------------|
| `<leader>wv` | Split vertical     |
| `<leader>ws` | Split horizontal   |
| `<leader>wq` | Close window       |
| `<leader>ww` | Save               |
| `<leader>wh` / `<leader>wl` | Focus left / right window |
| `<leader>wj` / `<leader>wk` | Focus lower / upper window |
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
| `<leader>os` | Personalize MIVN                 |

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
| `c` / `s` / `n` (ASM debugger) | Continue / step into / step over one instruction |
| `p` / `r` (ASM debugger) | Pause / restart |
| `a` / `v` (ASM debugger) | Focus assembly / source |
| `R` / `m` (ASM debugger) | Focus registers / memory |
| `j` / `k` / `<C-d>` / `<C-u>` (ASM debugger) | Scroll the focused panel; scrolling code or memory pauses auto-follow |
| `f` / `F` (ASM debugger) | Toggle code following / memory following |
| `K` (ASM)    | Show instruction documentation |
| `<C-k>` (ASM, insert mode) | Show operand signature help |

The ASM debugger keeps its program terminal hidden until it detects a read from stdin. When the input window appears, type a line and press `<Enter>`; the window closes and execution resumes. Program output from the hidden terminal is copied into the **PROGRAM OUTPUT** panel. Press `I` in a debugger panel to open the input terminal manually. In the debugger, use `a`/`v` to focus code, `R` for registers, and `m` for the memory dump. `j`/`k` and `<C-d>`/`<C-u>` scroll the focused panel. Scrolling assembly or source turns off automatic PC following so each refresh does not jump back; `f` toggles it. Scrolling memory pauses its automatic SP tracking; `F` toggles that tracking. Register and memory values refresh whenever execution stops after a step, breakpoint, or signal. GDB's complete register list is shown, including architecture-specific and SIMD registers, and can be scrolled in the register panel.

Input detection covers `read` and `readv` system calls with file descriptor 0 in GDB, falling back to common libc read functions when syscall catchpoints are unavailable. LLDB checks common `read` functions and source-mapped `svc`/`syscall` instructions.

### Snippets

Type a trigger in Insert mode and press `<Tab>` to expand it, like VS Code. `<Tab>` and `<S-Tab>` move through snippet fields; snippets are not launched from WhichKey. There are now more than 100 triggers across Assembly, C, C++, Python, Bash, Lua, JavaScript, TypeScript, HTML, CSS and JSON. Examples include `main`, `arm64_func`, `syscall`, `pytest`, `dataclass`, `class`, `async`, `component`, `html5`, `section`, `transition`, `flex` and `obj`. Snippet definitions live in `lua/snippets/`, one file per language; `lua/snippets/init.lua` registers their filetypes.

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
│   │   ├── cursor.lua
│   │   ├── status.lua
│   │   └── tabline.lua
│   ├── plugins/
│   │   ├── asm-debug.lua
│   │   ├── auto-session.lua
│   │   ├── autopairs.lua
│   │   ├── catppuccin.lua
│   │   ├── conform.lua
│   │   ├── completion.lua
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
│   ├── mivn/
│   │   ├── README.md
│   │   ├── dashboard.lua
│   │   ├── keymaps.lua
│   │   ├── settings.lua
│   │   ├── user_config.lua
│   │   └── theme.lua
│   ├── snippets/
│   │   ├── asm.lua
│   │   ├── c.lua
│   │   ├── cpp.lua
│   │   ├── css.lua
│   │   ├── html.lua
│   │   ├── init.lua
│   │   ├── javascript.lua
│   │   ├── json.lua
│   │   ├── lua.lua
│   │   ├── python.lua
│   │   ├── sh.lua
│   │   └── typescript.lua
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
