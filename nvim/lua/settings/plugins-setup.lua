-- Settings for plugins
vim.notify = require "notify"
require("mason").setup()

require("neotest").setup {
    adapters = {
        require("neotest-python")(
            {
                dap = {
                    justMyCode = false
                }
            }
        ),
        require("neotest-plenary")
    }
}

require("gp").setup {
    require("gp").setup {
        agents = {
            -- Disable ChatGPT 3.5
            {
                name = "ChatGPT3-5",
                disable = true
            },
            {
                name = "ChatGPT4",
                chat = true,
                command = true,
                -- string with model name or table with model name and parameters
                model = {
                    model = "gpt-4o",
                    temperature = 0.1,
                    top_p = 1
                },
                -- system prompt (use this to specify the persona/role of the AI)
                system_prompt = "You are a specialized coding AI assistant.\n\n" ..
                    "The user provided the additional info about how they would like you to respond:\n\n" ..
                        "- If you're unsure don't guess and say you don't know instead.\n" ..
                            "- Ask question if you need clarification to provide better answer.\n" ..
                                "- Think deeply and carefully from first principles step by step.\n" ..
                                    "- Make your answers short, conscience, to the point and helpful.\n" ..
                                        "- Produce only valid and actionable code.\n" ..
                                            "- Include only essencial response like code etc, DO NOT provide explanations unless specifically asked for\n" ..
                                                "- Take a deep breath; You've got this!"
            }
        }
    }
}

require("remote-sshfs").setup {}

require("mini.align").setup()
-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require("mini.ai").setup {n_lines = 500}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require("mini.surround").setup()
require("mini.files").setup {
    windows = {
        preview = true,
        width_focus = 100,
        width_preview = 100
    }
}

require("go").setup {
    gofmt = "gofumpt",
    lsp_gofumpt = true
}

require("goto-preview").setup {}

require("no-neck-pain").setup {
    width = 75,
    buffers = {
        colors = {
            background = "tokyonight-moon"
        },
        right = {
            enabled = false
        }
    }
}

require("gen").setup {
    model = "llama3:latest",
    show_model = true
}

require("mdeval").setup {
    -- Don't ask before executing code blocks
    require_confirmation = false,
    -- Change code blocks evaluation options.
    eval_options = {
        -- Set custom configuration for C++
        go = {
            command = {"go", "run"},
            extension = "go",
            exec_type = "interpreted", -- Since Go runs as 'go run' for scripts
            language_code = "go" -- Assuming the plugin can use this to identify code blocks
        },
        zsh = {
            command = {"zsh", "-c"},
            exec_type = "interpreted",
            language_code = "zsh",
            extension = "sh",
            default_header = [[
#!/usr/bin/env zsh
      ]]
        },
        cpp = {
            command = {"clang++", "-std=c++20", "-O0"},
            default_header = [[
    #include <iostream>
    #include <vector>
    using namespace std;
      ]]
        }
    }
}

require("obsidian").setup {
    workspaces = {
        {
            name = "main",
            path = "/Users/akashgoyal/Workspace/obsidian",
            -- Optional, override certain settings.
            overrides = {
                notes_subdir = "Notes"
            }
        },
        {
            name = "work",
            path = "/Users/akashgoyal/Workspace/obsidian"
        }
    },
    disable_frontmatter = false,
    -- open_app_foreground = true,
    templates = {
        subdir = "Templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M"
    },
    new_notes_location = "notes_subdir",
    -- Optional, configure additional syntax highlighting / extmarks.
    ui = {
        enable = false, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        -- Define how various check-boxes are displayed
        external_link_icon = {
            char = "",
            hl_group = "ObsidianExtLinkIcon"
        },
        -- Replace the above with this if you don't have a patched font:
        -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = {
            hl_group = "ObsidianRefText"
        },
        highlight_text = {
            hl_group = "ObsidianHighlightText"
        },
        tags = {
            hl_group = "ObsidianTag"
        },
        hl_groups = {
            -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
            ObsidianTodo = {
                bold = true,
                fg = "#f78c6c"
            },
            ObsidianDone = {
                bold = true,
                fg = "#89ddff"
            },
            ObsidianRightArrow = {
                bold = true,
                fg = "#f78c6c"
            },
            ObsidianTilde = {
                bold = true,
                fg = "#ff5370"
            },
            ObsidianRefText = {
                underline = true,
                fg = "#c792ea"
            },
            ObsidianExtLinkIcon = {
                fg = "#c792ea"
            },
            ObsidianTag = {
                italic = true,
                fg = "#89ddff"
            },
            ObsidianHighlightText = {
                bg = "#75662e"
            }
        }
    },
    follow_url_func = function(url)
        -- Open the URL in the default web browser.
        vim.fn.jobstart {"xdg-open", url} -- linux
    end,
    finder = "telescope.nvim",
    mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
            action = function()
                return require("obsidian").util.gf_passthrough()
            end,
            opts = {
                noremap = false,
                expr = true,
                buffer = true
            }
        },
        -- Toggle check-boxes.
        ["<leader>ch"] = {
            action = function()
                return require("obsidian").util.toggle_checkbox()
            end,
            opts = {
                buffer = true
            }
        }
    },
    note_path_func = function(spec)
        -- This is equivalent to the default behavior.
        local path = spec.dir / tostring(spec.title)
        return path:with_suffix ".md"
    end,
    wiki_link_func = function(opts)
        if opts.label ~= opts.path then
            return string.format("[[%s|%s]]", opts.path, opts.label)
        else
            return string.format("[[%s]]", opts.path)
        end
    end,
    completion = {
        nvim_cmp = true -- if using nvim-cmp, otherwise set to false
    }
}

require("todo-comments").setup {
    keywords = {
        PROJECT = {
            icon = " ", -- icon used for the sign, and in search results
            color = "info" -- can be a hex color, or a named color (see below)
            -- signs = false, -- configure signs for some keywords individually
        }
    }
}

require("nvim-treesitter.configs").setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {"bash", "c", "cmake", "cpp", "go", "java", "json", "lua", "make", "python", "rust"},
    -- List of parsers to ignore installing
    ignore_install = {},
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    autopairs = {
        enable = true
    },
    highlight = {
        enable = true, -- false will disable the whole extension
        -- disable = { "c", "rust" },  -- list of language that will be disabled
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = true
    },
    -- List of parsers to always install, useful for parsers without filetype
    modules = {},
    auto_install = true,
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil
    },
    indent = {
        enable = true,
        -- disable yaml indenting because the grammar is too simplistic, other plugins do it better
        disable = {"yaml"},
        additional_vim_regex_highlighting = {"markdown"}
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<c-space>",
            node_decremental = "<c-h>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>"
        }
    },
    textobjects = {
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner"
            },
            swap_previous = {
                ["<leader>b"] = "@parameter.inner"
            }
        },
        move = {
            enable = true,
            disable = {"yaml", "markdown"},
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer"
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer"
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer"
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer"
            }
        },
        lsp_interop = {
            enable = true,
            border = "none",
            peek_definition_code = {
                ["<leader>dF"] = "@function.outer"
            }
        },
        select = {
            enable = true,
            disable = {"yaml"},
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                -- nvim_buf_set_keymap) which plugins like which-key display
                ["ic"] = {
                    query = "@class.inner",
                    desc = "Select inner part of a class region"
                }
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
                ["@parameter.outer"] = "v", -- charwise
                ["@function.outer"] = "V", -- linewise
                ["@class.outer"] = "<c-v>" -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = false
        }
    }
}

require("femaco").setup {
    -- what to do after opening the float
    post_open_float = function(winnr)
        if vim.bo.filetype == "rust" then
            require("rust-tools.standalone").start_standalone_client()
        end
    end
}

require("which-key").setup {
    notify = false,
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20 -- how many suggestions should be shown in the list?
        }
    }
}

-- require('lualine').setup {
--   options = {
--     icons_enabled = true,
--     component_separators = '|',
--     section_separators = '',
--   },
--   sections = {
--     lualine_x = {
--       {
--         require("noice").api.statusline.mode.get,
--         cond = require("noice").api.statusline.mode.has,
--         color = { fg = "#ff9e64" },
--       },
--       {
--         require("noice").api.status.command.get,
--         cond = require("noice").api.status.command.has,
--         color = { fg = "#ff9e64" },
--       },
--     },
--     lualine_a = {
--       {
--         'buffers',
--       }
--     }
--   }
-- }

require("lualine").setup {
    options = {
        theme = "tokyonight",
        extensions = {}
    }
}

require("nvim-surround").setup {
    keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "d;",
        change = "c;"
    }
}

vim.g.indentLine_char = "⦙"
-- setup for netrw
vim.g.netrw_winsize = 30
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0
-- setup for markdown snippet
vim.g.vim_markdown_folding_disabled = 0
vim.g.vim_markdown_folding_style_pythonic = 1
vim.g.vim_markdown_folding_level = 2
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_conceal_code_blocks = 0
vim.g.vim_markdown_no_extensions_in_markdown = 1
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_follow_anchor = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
-- setup for syntastic
vim.g.syntastic_always_populate_loc_list = 0
vim.g.syntastic_auto_loc_list = 0
vim.g.syntastic_check_on_open = 0
vim.g.syntastic_check_on_wq = 0
vim.g.syntastic_python_checkers = "['flake8']"
-- setup for terraform
vim.g.terraform_fmt_on_save = 1
vim.g.terraform_align = 1
-- setup for ctrlp
vim.g.ctrlp_map = "<c-p>"
vim.g.ctrlp_cmd = "CtrlPMixed"
vim.g.ctrlp_working_path_mode = "ra"
vim.g.ctrlp_custom_ignore = "\\v[\\/]\\.(git|hg|svn)$"
vim.g.ctrlp_custom_ignore = {
    dir = {"\\v[\\/]\\.(git|hg|svn)$"},
    file = {"\\v\\.(exe|so|dll)$"},
    link = {"some_bad_symbolic_links"}
}
-- setup for indent line
vim.g.indentLine_char = "|"
vim.g.go_fmt_command = "goimports"
vim.g.go_highlight_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_structs = 1
vim.g.go_highlight_interfaces = 1
vim.g.go_highlight_operators = 1
vim.g.go_fmt_experimental = 1
-- Send to window
vim.g.sendtowindow_use_defaults = 0
-- Nerdcommenter
vim.g.NERDSpaceDelims = 1
-- Scrollfix
vim.g.scrollfix = -1
vim.g.rnvimr_enable_picker = 1
-- Startify
vim.g.startify_change_to_dir = 1
vim.g.startify_session_persistence = 0
vim.g.startify_change_to_vsc_root = 1
vim.g.startify_session_number = 0
vim.g.startify_files_number = 10
vim.g.startify_session_delete_buffers = 0
vim.g.startify_skiplist = {"^/tmp"}
vim.g.startify_commands = {
    {
        "Search Workspace    :SPC fd",
        "Telescope find_files search_dirs=~/Workspace,--hidden,--with-filename"
    },
    {
        "Search dotfiles     :SPC fr",
        'lua require\'telescope\'.extensions.repo.list{search_dirs = {"~/dotfiles-dev"}}'
    },
    {"Change Color        :SPC fc", "Telescope colorscheme"},
    {"Transparent Bg      :SPC tr", "TransparentEnable"},
    {"Pick Emoji          :SPC fm", "Telescope emoji"}
}
vim.g.startify_bookmarks = {
    "~/.config/nvim/lua",
    "~/.zshrc",
    "~/.private",
    "~/.aliases",
    "~/.exports",
    "~/.config/tmux/tmux.conf",
    "~/dotfiles-dev/zsh",
    "~/.local/share/nvim/gp/chats"
}
vim.g.startify_custom_header = "startify#pad(split(system('fortune -s | cowsay | lolcat; date'), '\n'))"
