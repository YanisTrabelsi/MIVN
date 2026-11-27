-- MIVN's editable settings. Save this file to apply live settings immediately.
-- Most plugin switches and options need a restart; theme, dashboard, and
-- language enablement update live. Keep strings in quotes and lists in { }.
return {
	theme = {
		flavour = "mocha", -- mocha, macchiato, frappe, latte
		transparent_background = true,
		transparent_floats = true,
		colors = {
			primary = "#CBA6F7", -- borders, title glow, active status
			secondary = "#A6F7B2", -- cursor line, active keys, status
			background = "#1E1E2E", -- background when transparency is disabled
			text = "#CDD6F4",
			muted = "#6C7086",
			surface = "#313244", -- opaque floating window background
			error = "#F38BA8",
			warning = "#F9E2AF",
			success = "#A6E3A1",
			info = "#89B4FA",
			visual = "#FAB387",
		},
	},

	dashboard = {
		language = "en", -- en, fr
		layout = "centered", -- centered, compact, top
		show_logo = true,
		title = "MIVN your editor",
		animation = {
			enabled = true,
			effect = "glow", -- glow, off
			period_ms = 9000, -- one slow pass across the title
			width = 3, -- number of softly lit characters on either side
		},
	},

	autosave = {
		enabled = true,
		delay_ms = 200, -- 50 to 2000; saves after edits outside Insert mode
	},

	key_history = {
		enabled = true,
		size = 16, -- number of recent key presses shown in the status bar
	},

	-- LSPs are enabled individually here. A server still needs to be installed.
	languages = {
		assembly = true,
		c = true,
		cpp = true, -- clangd handles C and C++ together
		python = true,
		bash = true,
		lua = true,
	},

	-- Disable a plugin with false; restart Neovim after changing these switches.
	plugins = {
		catppuccin = true, -- Colorscheme and palette.
		dashboard = true, -- Startup screen and settings shortcut.
		which_key = true, -- Shows leader-key shortcuts.
		noice = true, -- Floating command line and completion menu.
		telescope = true, -- Search files, text, buffers, and Git.
		oil = true, -- Edit directories as file lists.
		toggleterm = true, -- Floating terminal.
		treesitter = true, -- Syntax highlighting and indentation.
		autopairs = false, -- Closes brackets and quotes automatically.
		conform = false, -- Formats Python with Ruff when saving.
		lint = true, -- Reports Python issues with Flake8.
		lsp = true, -- Language servers for completion, navigation, and diagnostics.
		completion = true, -- Completion menu and snippet expansion.
		luasnip = true, -- Snippet engine used by completion.
		friendly_snippets = true, -- Community snippets for LuaSnip.
		auto_session = true, -- Saves and restores editor sessions.
		undotree = true, -- Browse and switch between edit history states.
		hlchunk = true, -- Indent guides and code block highlights.
		render_markdown = true, -- Renders Markdown headings, lists, and code.
	},

	-- Common settings for each plugin, grouped by the switch name above.
	-- Advanced native settings go in that plugin's `setup` table.
	plugin_options = {
		-- Dashboard startup screen.
		dashboard = {
			setup = {
				hide = { statusline = false }, -- keep the status bar visible on the dashboard
			},
		},
		-- Catppuccin colorscheme.
		catppuccin = {
			term_colors = true,
			integrations = { which_key = false },
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				functions = { "italic", "bold" },
			},
		},
		-- Leader-key shortcut popup.
		which_key = {
			border = "rounded", -- rounded, single, double, shadow, none
			spacing = 3,
			layout_width = { min = 20, max = 50 },
			padding = { 1, 2 },
			icons = true,
			delay = 300,
			setup = {}, -- advanced WhichKey options
		},
		-- Search and picker windows.
		telescope = {
			sorting_strategy = "ascending",
			layout_strategy = "horizontal", -- horizontal, vertical, flex, cursor, bottom_pane
			prompt_position = "bottom", -- bottom, top
			width = 0.85,
			height = 0.85,
			preview_width = 0.55,
			results_width = 0.45,
			preview_cutoff = 120,
			path_display = { "truncate" },
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			winblend = 0,
			color_devicons = true,
			defaults = {}, -- advanced Telescope defaults
			extensions = {},
			setup = {}, -- advanced Telescope options
		},
		-- File explorer.
		oil = {
			show_hidden = true,
			natural_order = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			float = { padding = 2, max_width = 90, max_height = 30, border = "rounded" },
			setup = {}, -- advanced Oil options
		},
		-- Embedded terminal.
		toggleterm = {
			direction = "float", -- float, horizontal, vertical, tab
			border = "rounded", -- rounded, single, double, shadow
			shade_terminals = false,
			winblend = 32,
			open_mapping = "<leader>ot",
			insert_mappings = false,
			setup = {}, -- advanced ToggleTerm options
		},
		-- Syntax parsers and indentation.
		treesitter = {
			parsers = { "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript", "html", "css", "json", "markdown", "asm" },
			indent = true,
			setup = {}, -- advanced nvim-treesitter options
		},
		-- Automatic matching brackets and quotes.
		autopairs = { check_treesitter = true, setup = {} },
		-- Completion menu and snippet expansion.
		completion = {
			snippets = true,
			friendly_snippets = true,
			select_first = true,
			snippet_priority = 2000, -- prefer MIVN snippets when triggers overlap
			setup = {},
		},
		-- Formatters that run when a buffer is saved.
		conform = {
			format_on_save = true,
			timeout_ms = 500,
			lsp_format = "fallback", -- never, fallback, prefer, first, last
			formatters_by_ft = { python = { "ruff_format" } },
			setup = {},     -- advanced conform.nvim options
		},
		-- Linters and the events that trigger them.
		lint = {
			linters_by_ft = { python = { "flake8" } },
			events = { "BufEnter", "BufWritePost" },
		},
		-- Language servers, Mason installs, and per-server settings.
		lsp = {
			ensure_installed = true,
			mason = {},  -- Mason's native setup options
			mason_lspconfig = {}, -- mason-lspconfig's native setup options
			capabilities = {},
			servers = {
				-- Add server options keyed by name; use enabled = true for extra servers.
				-- Set ensure_installed = true to ask Mason to install an extra server.
				-- lua_ls = { settings = { Lua = { telemetry = { enable = false } } } },
				-- pyright = { enabled = false },
			},
		},
		-- Session save and restore behavior.
		auto_session = {
			auto_save = true,
			auto_restore = false,
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			setup = {}, -- advanced auto-session options
		},
		-- Indent guides and code block highlights.
		hlchunk = {
			chunk = true,
			indent = true,
			line_num = true,
			blank = false,
			max_file_size = 1048576,
			indent_colors = { "#313244", "#3B3A52", "#45455A" },
			setup = {}, -- advanced hlchunk options
		},
		-- Command line and completion menu appearance.
		noice = {
			cmdline = true,
			popupmenu = true,
			-- Leave native Neovim notifications enabled, even with Noice installed.
			native_notifications = true,
			cmdline_position = { row = "95%", col = "50%" },
			cmdline_size = { width = 25, height = "auto" },
			popupmenu_position = { row = 8, col = "50%" },
			popupmenu_size = { width = 60, height = 10 },
			border = "rounded",
			setup = {}, -- advanced Noice options
		},
		-- Markdown rendering options (native render-markdown settings).
		render_markdown = {},
	},
}
