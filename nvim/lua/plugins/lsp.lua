local utils = require("utils")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, {
      buffer = bufnr,
      desc = desc,
    })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, {
    desc = "Format current buffer with LSP",
  })
end

-- Setup mason so it can manage external tooling
require("mason").setup()

-- Enable the following language servers
-- Feel free to add/remove any LSPs that you want here. They will automatically be installed
local servers = { "rust_analyzer", "pyright", "gopls" }

-- Ensure the servers above are installed
require("mason-lspconfig").setup({
  ensure_installed = servers,
})

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

for _, lsp in ipairs(servers) do
  require("lspconfig")[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Turn on lsp status information
require("fidget").setup()

-- Example custom configuration for lua
--
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local lspconfig = require("lspconfig")

if utils.executable("pylsp") then
  local venv_path = os.getenv("VIRTUAL_ENV")
  local py_path = nil
  -- decide which python executable to use for mypy
  if venv_path ~= nil then
    py_path = venv_path .. "/bin/python3"
  else
    py_path = vim.g.python3_host_prog
  end

  lspconfig.pylsp.setup({
    on_attach = on_attach,
    settings = {
      pylsp = {
        plugins = {
          -- formatter options
          black = {
            enabled = true,
          },
          autopep8 = {
            enabled = false,
          },
          yapf = {
            enabled = false,
          },
          -- linter options
          pylint = {
            enabled = true,
            executable = "pylint",
          },
          ruff = {
            enabled = false,
          },
          pyflakes = {
            enabled = false,
          },
          pycodestyle = {
            enabled = false,
          },
          -- type checker
          pylsp_mypy = {
            enabled = true,
            overrides = { "--python-executable", py_path, true },
            report_progress = true,
            live_mode = false,
          },
          -- auto-completion options
          jedi_completion = {
            fuzzy = true,
          },
          -- import sorting
          isort = {
            enabled = true,
          },
        },
      },
    },
    flags = {
      debounce_text_changes = 200,
    },
    capabilities = capabilities,
  })
else
  vim.notify("pylsp not found!", vim.log.levels.WARN, {
    title = "Nvim-config",
  })
end

if utils.executable("pyright") then
  lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
else
  vim.notify("pyright not found!", vim.log.levels.WARN, {
    title = "Nvim-config",
  })
end

if utils.executable("ltex-ls") then
  lspconfig.ltex.setup({
    on_attach = on_attach,
    cmd = { "ltex-ls" },
    filetypes = { "text", "plaintex", "tex", "markdown" },
    settings = {
      ltex = {
        language = "en",
      },
    },
    flags = {
      debounce_text_changes = 300,
    },
  })
end

if utils.executable("clangd") then
  lspconfig.clangd.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "clangd", "--offset-encoding=utf-16" },
    filetypes = { "c", "cpp", "hpp", "h", "objc", "objcpp", "cuda", "proto" },
    flags = {
      debounce_text_changes = 500,
    },
    settings = {
      ["clangd"] = {
        ["compilationDatabasePath"] = "build",
        ["fallbackFlags"] = { "-std=c++17" },
      },
    },
    single_file_support = true,
  })
end

-- set up vim-language-server
if utils.executable("vim-language-server") then
  lspconfig.vimls.setup({
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 500,
    },
    capabilities = capabilities,
  })
else
  vim.notify("vim-language-server not found!", vim.log.levels.WARN, {
    title = "Nvim-config",
  })
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
  lspconfig.bashls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

if utils.executable("lua-language-server") then
  -- settings for lua-language-server can be found on https://github.com/LuaLS/lua-language-server/wiki/Settings .
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
      },
    },
    capabilities = capabilities,
  })
end

require("lspconfig").lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = "LuaJIT",
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.lsp.start({
      name = "bash-language-server",
      cmd = { "bash-language-server", "start" },
    })
  end,
})
