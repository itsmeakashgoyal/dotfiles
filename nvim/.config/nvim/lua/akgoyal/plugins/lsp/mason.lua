--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/lsp/mason.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Mason: LSP/DAP/formatter/linter installer, plus native LSP server config (clangd, pyright,
-- bashls, lua_ls, gopls) and on-attach keymaps.
return {
	"williamboman/mason.nvim",
	lazy = false,
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"neovim/nvim-lspconfig",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- ======================================================================
		-- Mason setup (binary installer)
		-- ======================================================================
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"clangd",
				"pyright",
				"bashls",
				"lua_ls",
				"gopls",
			},
			automatic_enable = false, -- we call vim.lsp.enable() ourselves
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"clang-format", -- C/C++ formatter
				"codelldb", -- C/C++ debugger
				"black", -- Python formatter
				"isort", -- Python import sorter
				"pylint", -- Python linter
				"shfmt", -- Shell formatter
				"shellcheck", -- Shell linter
				"stylua", -- Lua formatter
				"debugpy", -- Python debugger
				"goimports", -- Go import organizer
				"gofumpt", -- Go formatter
				"rust-analyzer", -- Rust language server
			},
		})

		-- ======================================================================
		-- Native LSP configuration (Neovim 0.12+)
		-- ======================================================================

		-- Global capabilities for all servers (nvim-cmp integration)
		vim.lsp.config("*", {
			capabilities = cmp_nvim_lsp.default_capabilities(),
		})

		-- Lua Language Server (with Neovim-specific settings)
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		-- Clangd (C/C++)
		vim.lsp.config("clangd", {
			cmd = { "clangd", "--offset-encoding=utf-16" },
			filetypes = { "c", "cpp", "hpp", "h", "objc", "objcpp", "cuda" },
			settings = {
				clangd = {
					compilationDatabasePath = "build",
					fallbackFlags = { "-std=c++17" },
				},
			},
			single_file_support = true,
		})

		-- Pyright (Python)
		vim.lsp.config("pyright", {
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
					},
				},
			},
		})

		-- Bash Language Server
		vim.lsp.config("bashls", {
			filetypes = { "sh", "bash", "zsh" },
		})

		-- Go Language Server
		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
					gofumpt = true,
				},
			},
		})

		-- Enable all configured servers
		vim.lsp.enable({ "lua_ls", "clangd", "pyright", "bashls", "gopls" })

		-- ======================================================================
		-- LSP Keymaps (on attach)
		-- ======================================================================
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Show LSP references"
				vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				vim.keymap.set({ "n", "v" }, "<leader>vca", function()
					vim.lsp.buf.code_action()
				end, opts)

				opts.desc = "Smart rename (incremental)"
				vim.keymap.set("n", "<leader>rn", function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end, { expr = true, buffer = ev.buf, desc = "Incremental rename" })

				opts.desc = "Show buffer diagnostics"
				vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

				vim.keymap.set("i", "<C-h>", function()
					vim.lsp.buf.signature_help()
				end, opts)
			end,
		})

		-- ======================================================================
		-- Diagnostics
		-- ======================================================================
		local signs = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		}

		vim.diagnostic.config({
			signs = {
				text = signs,
			},
			virtual_text = true,
			underline = true,
			update_in_insert = false,
		})
	end,
}
