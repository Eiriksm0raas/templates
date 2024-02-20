-- Disabling netrw, the default file tree
-- Enabling nvim tree later
vim.g.loaded_netrw = 1
vim.g.loaded_ntrwPlugin = 1

-- Some visual setup
vim.opt.termguicolors = true
vim.cmd[[colorscheme darkblue]]
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Only highlight search matches while searching
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.g.mapleader = " "
vim.o.splitright = true

-- Enable line numbers
vim.opt.number = true

-- Enable syntax highlight
vim.cmd[[syntax enable]]

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Default tabing
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.scrolloff = 8

-- Custom commands
function SetTabWidth(num)
	vim.opt.tabstop = num
	vim.opt.shiftwidth = num
end

function SetInvisBackground()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

vim.cmd[[
	command! -nargs=1 Tw :lua SetTabWidth(tonumber(<q-args>))
	command! -nargs=0 Bg :lua SetInvisBackground()
	command! -nargs=0 Space :set expandtab
	command! -nargs=0 Tab :set noexpandtab
]]

-- Plugins
-- Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Nvim tree
	"nvim-tree/nvim-tree.lua", {
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {
				filters = {
					dotfiles = true,
				},
			}
			vim.keymap.set("n", "<Leader>f", ":NvimTreeToggle<cr>")
		end,
	},
	-- Lexima, auto closes parenthesis etc.
	"cohama/lexima.vim", {
		"cohama/lexima.vim",
		version = "*",
	},
	-- Telescope, fuzzy finder/ grep
	"nvim-telescope/telescope.nvim", {
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"BurntSushi/ripgrep",
		},
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<Leader>sf", builtin.find_files, {})
			vim.keymap.set("n", "<Leader>sg", function()
				if not pcall(builtin.git_files) then
					print("Did not find git repository")
				end
			end, {})
		end,
	},
	-- Treesitter for syntax hilightning
	"nvim-treesitter/nvim-treesitter", {
		"nvim-treesitter/nvim-treesitter",
		build = ":TsUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Add languages here
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"cpp",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	-- LSPZero, easier lsp and autocomplete configutaion
	"VonHeikemen/lsp-zero.nvim", {
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- AutoCompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "L3MON4D3/LuaSnip" },
		},
		config = function()
			local lspz = require("lsp-zero").preset({})
			local cmp = require("cmp")
			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			-- List of language servers
			lspz.ensure_installed({
				"lua_ls",
				"clangd",
				"cmake-language-server"
			})

			-- Bindings for selecting suggestions
			lspz.setup_nvim_cmp({
				mapping = lspz.defaults.cmp_mappings({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					--["<C-Enter>"] = cmp.mapping.confirm({ select = true }),
				}),
			})

			local function on_attach(_, buffnr)
				local opts = { buffer = buffnr }
				lspz.default_keymaps(opts)

				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			end

			-- Default keybinds. Might change later
			lspz.on_attach(on_attach)

			-- Configure lua language server for neovim
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup(lspz.nvim_lua_ls())

			-- Clangd config for error levels
			lspconfig.clangd.setup {
				on_attach = on_attach,
				settings = {
					clangd ={
						diagnostic = {
							severityAdjustments = {
								Information = "Hint",
								Warning = "Error",
							},
						},
					},
				},
			}

			lspz.setup()
		end,
	},
})
