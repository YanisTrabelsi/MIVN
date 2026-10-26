local settings = require("mivn.settings")
local options = settings.plugin_options("completion")
local snippets_enabled = options.snippets ~= false and settings.plugin_enabled("luasnip")
local friendly_snippets_enabled = snippets_enabled
	and options.friendly_snippets ~= false
	and settings.plugin_enabled("friendly_snippets")
local dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-cmdline" }
if snippets_enabled then
	dependencies[#dependencies + 1] = "L3MON4D3/LuaSnip"
	dependencies[#dependencies + 1] = "saadparwaiz1/cmp_luasnip"
	if friendly_snippets_enabled then
		dependencies[#dependencies + 1] = "rafamadriz/friendly-snippets"
	end
end

return {
	"hrsh7th/nvim-cmp",
	enabled = settings.plugin_enabled("completion"),
	dependencies = dependencies,
	config = function()
		require("mivn.theme").apply()
		local cmp = require("cmp")
		local luasnip
		if snippets_enabled then
			if friendly_snippets_enabled then
				require("luasnip.loaders.from_vscode").lazy_load()
			end
			luasnip = require("luasnip")
			luasnip.config.setup({ history = true, update_events = "TextChanged,TextChangedI" })
			require("snippets").register(luasnip, options.snippet_priority)
		end

		local sources = { { name = "nvim_lsp" } }
		if snippets_enabled then
			sources[#sources + 1] = { name = "luasnip" }
		end
		local mapping = cmp.mapping.preset.insert({
			["<Tab>"] = cmp.mapping(function(fallback)
				if luasnip and luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if luasnip and luasnip.jumpable(-1) then
					luasnip.jump(-1)
				elseif cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<CR>"] = cmp.mapping.confirm({ select = options.select_first ~= false }),
			["<C-Space>"] = cmp.mapping.complete(),
		})

		local setup = {
			snippet = {
				expand = function(args)
					if luasnip then
						luasnip.lsp_expand(args.body)
					else
						vim.snippet.expand(args.body)
					end
				end,
			},
			window = {
				completion = { border = "rounded", winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder" },
				documentation = { border = "rounded", winhighlight = "Normal:CmpNormal,FloatBorder:CmpDocBorder" },
			},
			mapping = mapping,
			sources = sources,
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		cmp.setup(setup)

		cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "cmdline" } } })
		cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
	end,
}
