# MIVN — Neovim Config

A Neovim configuration with a customizable dashboard and language tools.

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
- **undotree** — Visual undo history (`<leader>u`); `j`/`k` switch live between states
- **conform.nvim** — Format Python with Ruff on save
- **nvim-lint** — Lint Python with Flake8
- **Auto-save** — Saves edits after a short delay outside Insert mode and on leaving Insert mode; formatters run only on save

### LSP
- **nvim-lspconfig** + **mason.nvim** — LSP management; Mason installs Pyright, Bash Language Server, Lua Language Server, and Clangd on supported platforms
- **nvim-cmp** — Autocompletion; LuaSnip and Friendly Snippets can be toggled separately
- **asm-lsp** — Assembly instruction completion, hover documentation, and operand signature help; enabled when installed on `PATH`

For Assembly files, completion appears while typing or can be opened with `<C-Space>`. Use `K` over an instruction for its documentation and `<C-k>` in insert mode for operand signature help. Assembly indentation keeps labels and directives at column zero and indents instructions beneath labels by four spaces. `asm-lsp` defaults to x86/x86-64; set the architecture and assembler for a project in its `.asm-lsp.toml` file when using another target. For example, ARM64 GAS projects can use:

```toml
[default_config]
assembler = "gas"
instruction_set = "arm64"
```

### Session
- **auto-session** — Automatic session save per directory, with manual restore

### Personalization
- Open **Edit MIVN settings** from the dashboard, press `<leader>os`, or run `:MivnSettings`. It opens [lua/mivn/user_config.lua](lua/mivn/user_config.lua), a normal Lua file with editable values and comments explaining each plugin. Save it to reload appearance, dashboard, auto-save, key history, and LSP language enablement. Plugin on/off switches and plugin options require restarting Neovim. If the file has a Lua syntax error, MIVN keeps the last valid settings and reports the error.
- Each entry under `plugins` can be set to `false` to disable that plugin, or `true` to re-enable it. Related settings are grouped under `plugin_options` (Catppuccin, WhichKey, Telescope, Oil, ToggleTerm, Treesitter, completion, formatters, linters, LSP servers, sessions, Noice and more). Plugin options include common settings and an advanced `setup` table for the plugin's native configuration; LSP servers have their own options. Set `theme.transparent_floats` or `theme.transparent_background` to `false` only if you want opaque windows; both are transparent by default. Neovim's native notifications remain enabled by default.
- Files changed outside Neovim are reloaded automatically when their buffers have no unsaved local edits. MIVN auto-saves edits outside Insert mode, so configuration files update without a write confirmation prompt.
- The status bar shows the most recent typed keys, with the newest key at the right. Change `key_history.enabled` and `key_history.size` in `lua/mivn/user_config.lua` to disable the history or choose how many keys it keeps (1–100).
- In a ToggleTerm window, press `<C-Space>` to leave terminal input mode and move through terminal output with normal-mode navigation keys. Press `i` to return to terminal input.
- In Undotree (`<leader>u`), `j`/`k` or the arrow keys move through history and immediately show that version in the buffer; `<Enter>` applies the selected version, and `q` closes the history. The diff panel stays visible while browsing. These switches only change the current buffer and remain undoable; save the file normally to write it to disk.

## Keybinds

Leader key: `<Space>`

| Key | Action |
|---|---|
| `<leader><leader>` / `<leader>ff` | Find files |
| `<leader>fr` / `<leader>fg` / `<leader>fh` | Recent files / search in files / help tags |
| `<leader>fb` / `<leader>bb` | Open buffers / choose a buffer |
| `<leader>gf` / `<leader>gs` / `<leader>gc` | Git files / status / commits |
| `<leader>bd` / `<leader>bn` / `<leader>bp` | Delete / next / previous buffer |
| `<leader>os` / `<leader>oc` / `<leader>od` | MIVN settings / `init.lua` / dashboard |
| `<leader>of` / `<leader>ot` | File explorer / terminal |
| `<leader>wh` / `wj` / `wk` / `wl` | Focus left / down / up / right window |
| `<leader>wH` / `wJ` / `wK` / `wL` | Move window to left / bottom / top / right edge |
| `<leader>w+` / `w-` | Increase / decrease window height |
| `<leader>w>` / `w<` | Increase / decrease window width |
| `<leader>w=` | Equalize window sizes |
| `<leader>wv` / `ws` / `wq` | Split vertically / horizontally / close window |
| `<leader>to` / `tc` | Open / close tab |
| `<leader>tn` / `tp` / `tf` / `tl` | Next / previous / first / last tab |
| `<leader>t>` / `t<` | Move tab right / left |
| `<leader>ww` | Save current buffer |
| `<leader>qq` | Quit Neovim |
| `<leader>ss` / `sr` / `sf` | Save / restore / find session |
| `<leader>lg` / `lR` / `li` / `lt` | Definition / references / implementation / type definition |
| `<leader>lh` / `lr` / `la` / `ld` / `ln` / `lp` / `lf` | Hover / rename / code action / diagnostic list / next / previous / format |
| `K` (ASM) / `<C-k>` in Insert mode | Instruction docs / operand help |

WhichKey labels the main groups directly: `b` means **Buffer**, `t` means **Tabs**, and `w` means **Window**. It shows each shortcut's action; disabling WhichKey does not remove the shortcuts. Plugin-specific mappings only appear when their plugin is enabled.

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
│   ├── asm_indent.lua
│   ├── autocmd/
│   │   ├── autosave.lua
│   │   ├── cursor.lua
│   │   ├── external_changes.lua
│   │   ├── status.lua
│   │   └── tabline.lua
│   ├── plugins/
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
