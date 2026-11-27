# MIVN configuration map

Start with [`user_config.lua`](user_config.lua). It is the only settings file most people need to edit: appearance, dashboard, auto-save, language servers, plugin switches, and plugin options are grouped there with comments.

| File | Purpose |
|---|---|
| `settings.lua` | Reads and validates `user_config.lua`; reloads it after save; tells you when a restart is needed. |
| `theme.lua` | Applies colors, transparency, and Catppuccin options. |
| `dashboard.lua` | Builds the dashboard and its slow title glow. |
| `keymaps.lua` | Defines normal editor shortcuts independently from WhichKey. |
| `key_history.lua` | Tracks recent typed keys for the status bar, with configurable enable and length settings. |
| `../autocmd/status.lua` | Restores MIVN's status line and number column when leaving the dashboard. |
| `../plugins/*.lua` | One Lazy.nvim specification per plugin; reads enable switches and options from `user_config.lua`. |
| `../snippets/*.lua` | One LuaSnip collection per language. |

Use `:MivnSettings` to open the settings file. A normal save reloads live appearance, dashboard, auto-save, key history, navigation, and language enablement; use `:MivnSettingsReload` to force a reload. Set `key_history.enabled` to `false` to hide recent keys or change `key_history.size` (1–100) to choose the list length. Set `navigation.disable_arrow_keys` or `navigation.disable_numpad_numbers` to `false` to restore those keys; changes apply immediately. Keypad digits can only be blocked when the terminal sends them as distinct keypad keycodes. Plugin switches and plugin options require a Neovim restart. If Lua syntax is invalid, MIVN keeps the last valid settings and reports the error.

Every key under `plugins` controls one plugin or dependency group. Set it to `false` to disable it and back to `true` to enable it. LuaSnip and Friendly Snippets can be switched independently; they also depend on the main completion plugin being enabled. Each `plugin_options` table exposes MIVN's common settings; for advanced setup, use that plugin's native fields inside its `setup` table. LSP server options go under `plugin_options.lsp.servers`; extra servers can be added with `enabled = true`, and optionally `ensure_installed = true`.

WhichKey shows the available mappings after pressing the leader key. Its group labels follow the plugin switches, while the actual shortcuts live in `keymaps.lua` or with their plugin, so turning WhichKey off does not remove those shortcuts. Snippets are expanded by typing their trigger and pressing Tab. Undotree opens with its history and diff visible; `j`/`k` and the arrow keys immediately switch the current buffer to the selected history state, `<Enter>` applies the selected state, and `q` closes the panel. These history changes remain undoable until you save the file.

For a new plugin, add its `true`/`false` switch and option table in `user_config.lua`, then read those values from that plugin's Lazy.nvim specification. Keep each plugin's setup in its own file under `lua/plugins/`.
