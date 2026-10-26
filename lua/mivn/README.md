# MIVN configuration map

Start with [`user_config.lua`](user_config.lua). It is the only settings file most people need to edit: appearance, dashboard, auto-save, language servers, plugin switches, and plugin options are grouped there with comments.

| File | Purpose |
|---|---|
| `settings.lua` | Reads and validates `user_config.lua`; reloads it after save; tells you when a restart is needed. |
| `theme.lua` | Applies colors, transparency, and Catppuccin options. |
| `dashboard.lua` | Builds the dashboard and its slow title glow. |
| `keymaps.lua` | Defines normal editor shortcuts independently from WhichKey. |
| `../autocmd/status.lua` | Restores MIVN's status line and number column when leaving the dashboard. |
| `../plugins/*.lua` | One Lazy.nvim specification per plugin; reads enable switches and options from `user_config.lua`. |
| `../snippets/*.lua` | One LuaSnip collection per language. |

Use `:MivnSettings` to open the settings file. A normal save reloads live appearance, dashboard, auto-save, and language enablement; use `:MivnSettingsReload` to force a reload. Plugin switches and plugin setup options require a Neovim restart.

Every key under `plugins` controls one plugin or dependency group. Set it to `false` to disable it and back to `true` to enable it. The ASM debugger depends on Telescope, so it stays disabled while Telescope is off. LuaSnip and Friendly Snippets can be switched independently; they also depend on the main completion plugin being enabled. Each `plugin_options` table exposes MIVN's common settings; for advanced setup, use that plugin's native fields inside its `setup` table. LSP server options go under `plugin_options.lsp.servers`; extra servers can be added with `enabled = true`, and optionally `ensure_installed = true`.

WhichKey shows the available mappings after pressing the leader key. Its group labels follow the plugin switches, while the actual shortcuts live in `keymaps.lua` or with their plugin, so turning WhichKey off does not remove those shortcuts. Snippets are expanded by typing their trigger and pressing Tab.

For a new plugin, add its `true`/`false` switch and option table in `user_config.lua`, then read those values from that plugin's Lazy.nvim specification. Keep each plugin's setup in its own file under `lua/plugins/`.
