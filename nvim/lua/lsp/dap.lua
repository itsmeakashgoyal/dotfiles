local dap, dapui = require "dap", require "dapui"

require("dapui").setup()

require("dap-go").setup {
    -- :help dap-configuration
    dap_configurations = {{
        -- Must be "go" or it will be ignored by the plugin
        type = "go",
        name = "Attach remote",
        mode = "remote",
        request = "attach"
    }},
    -- delve configurations
    delve = {
        -- time to wait for delve to initialize the debug session.
        -- default to 20 seconds
        initialize_timeout_sec = 20,
        -- a string that defines the port to start delve debugger.
        -- default to string "${port}" which instructs nvim-dap
        -- to start the process in a random available port
        port = "${port}"
    }
}

dap.configurations.lua = {{
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance"
}}

dap.adapters.nlua = function(callback, config)
    callback {
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 8086
    }
end

-- CPP
-- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
-- vscode-cpptools are installed via MASON

dap.configurations.c = dap.configurations.cpp

-- PYTHON
-- : https://github.com/mfussenegger/nvim-dap-python
dap_python_ok, dap_python = pcall(require, "dap-python")
if not dap_python_ok then
    print("dap-python not found")
    return
end

dap_python.setup('~/.virtualenvs/debugpy/bin/python')

-- this comes from https://github.com/theHamsta/nvim-dap-virtual-text
-- to have values of variables in the editor
-- require("nvim-dap-virtual-text").setup {
--  commented = true,
-- }

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
