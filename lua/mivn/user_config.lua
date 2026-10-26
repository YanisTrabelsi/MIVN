-- MIVN's editable settings. Change the values here, save, and the appearance
-- and live options reload automatically. Plugin on/off switches take effect
-- after restarting Neovim. Keep strings in quotes and lists inside { }.
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

	-- LSPs are enabled individually here. A server still needs to be installed.
	languages = {
		assembly = true,
		c = true,
		cpp = true, -- clangd handles C and C++ together
		python = true,
		bash = true,
		lua = true,
	},

	-- Disable any plugin with false. Re-enable it with true, then restart Neovim.
	-- The ASM debugger uses Telescope for its executable picker, so disabling
	-- Telescope also disables the debugger until Telescope is enabled again.
	plugins = {
		catppuccin = true,
		dashboard = true,
		which_key = true,
		noice = true,
		telescope = true,
		oil = true,
		toggleterm = true,
		treesitter = true,
		autopairs = true,
		conform = true,
		lint = true,
		lsp = true,
		completion = true,
		luasnip = true,
		friendly_snippets = true,
		asm_debug = true,
		auto_session = true,
		undotree = true,
		hlchunk = true,
		render_markdown = true,
	},

	-- Plugin options are kept together here so their settings are easy to find.
	-- For advanced options, each plugin's `setup` table is merged into its native
	-- setup call. Catppuccin and render-markdown use their native options directly.
	plugin_options = {
		asm_debug = {
			follow_code = true, -- keep the current instruction in view after each pause
			follow_memory = true, -- keep the stack dump centered around SP
		},
		dashboard = { setup = {} }, -- advanced dashboard-nvim options
		catppuccin = {
			term_colors = true,
			integrations = { which_key = false },
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				functions = { "italic", "bold" },
			},
		},
		which_key = {
			border = "rounded", -- rounded, single, double, shadow, none
			spacing = 3,
			layout_width = { min = 20, max = 50 },
			padding = { 1, 2 },
			icons = true,
			delay = 300,
			setup = {}, -- advanced WhichKey options
		},
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
		oil = {
			show_hidden = true,
			natural_order = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			float = { padding = 2, max_width = 90, max_height = 30, border = "rounded" },
			setup = {}, -- advanced Oil options
		},
		toggleterm = {
			direction = "float", -- float, horizontal, vertical, tab
			border = "rounded", -- rounded, single, double, shadow
			shade_terminals = false,
			winblend = 32,
			open_mapping = "<leader>ot",
			insert_mappings = false,
			setup = {}, -- advanced ToggleTerm options
		},
		treesitter = {
			parsers = { "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript", "html", "css", "json", "markdown", "asm" },
			indent = true,
			setup = {}, -- advanced nvim-treesitter options
		},
		autopairs = { check_treesitter = true, setup = {} },
		completion = {
			snippets = true,
			friendly_snippets = true,
			select_first = true,
			snippet_priority = 2000, -- prefer MIVN snippets when triggers overlap
			setup = {},
		},
		conform = {
			format_on_save = true,
			timeout_ms = 500,
			lsp_format = "fallback", -- never, fallback, prefer, first, last
			formatters_by_ft = { python = { "ruff_format" } },
			setup = {}, -- advanced conform.nvim options
		},
		lint = {
			linters_by_ft = { python = { "flake8" } },
			events = { "BufEnter", "BufWritePost" },
		},
		lsp = {
			ensure_installed = true,
			mason = {}, -- Mason's native setup options
			mason_lspconfig = {}, -- mason-lspconfig's native setup options
			capabilities = {},
			servers = {
				-- Add server options keyed by name; use enabled = true for extra servers.
				-- Set ensure_installed = true to ask Mason to install an extra server.
				-- lua_ls = { settings = { Lua = { telemetry = { enable = false } } } },
				-- pyright = { enabled = false },
			},
		},
		auto_session = {
			auto_save = true,
			auto_restore = false,
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			setup = {}, -- advanced auto-session options
		},
		hlchunk = {
			chunk = true,
			indent = true,
			line_num = true,
			blank = false,
			max_file_size = 1048576,
			indent_colors = { "#313244", "#3B3A52", "#45455A" },
			setup = {}, -- advanced hlchunk options
		},
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
		render_markdown = {}, -- render-markdown.nvim's native options
	},
}
