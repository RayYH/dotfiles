local api = vim.api
local fn = vim.fn

local function setup_dap_signs_and_highlights()
    -- Highlights
    local hl_defs = {
        DapBreakpoint = { fg = "#993939", bg = "#292E42", ctermbg = 0 },
        DapLogPoint   = { fg = "#61afef", bg = "#292E42", ctermbg = 0 },
        DapStopped    = { fg = "#98c379", bg = "#292E42", ctermbg = 0 },
    }

    for group, opts in pairs(hl_defs) do
        api.nvim_set_hl(0, group, opts)
    end

    -- Signs
    local signs = {
        DapBreakpoint = {
            text = "",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        },
        DapBreakpointCondition = {
            text = "ﳁ",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        },
        DapBreakpointRejected = {
            text = "",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        },
        DapLogPoint = {
            text = "",
            texthl = "DapLogPoint",
            linehl = "DapLogPoint",
            numhl = "DapLogPoint",
        },
        DapStopped = {
            text = "",
            texthl = "DapStopped",
            linehl = "DapStopped",
            numhl = "DapStopped",
        },
    }

    for name, opts in pairs(signs) do
        fn.sign_define(name, opts)
    end
end

return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },

    -- Load lazily; you only need this when debugging
    event = "VeryLazy",

    -- use opts + config pattern
    opts = {
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "",
            },
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
            border = "single",
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
        force_buffers = true,
        icons = {
            collapsed = "",
            current_frame = "",
            expanded = "",
        },
        layouts = {
            {
                elements = {
                    { id = "scopes",      size = 0.25 },
                    { id = "breakpoints", size = 0.25 },
                    { id = "stacks",      size = 0.25 },
                    { id = "watches",     size = 0.25 },
                },
                position = "left",
                size = 40,
            },
            {
                elements = {
                    { id = "repl", size = 1.0 },
                    -- { id = "console", size = 0.5 },
                },
                position = "bottom",
                size = 10,
            },
        },
        mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t",
        },
        render = {
            indent = 1,
            max_value_lines = 100,
        },
    },

    config = function(_, opts)
        local dap_ok, dap = pcall(require, "dap")
        if not dap_ok then
            return
        end

        local dapui_ok, dapui = pcall(require, "dapui")
        if not dapui_ok then
            return
        end

        dapui.setup(opts)

        local listeners = dap.listeners

        -- Open UI when a session starts
        listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        listeners.before.launch.dapui_config = function()
            dapui.open()
        end

        -- Close UI when session ends
        listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        setup_dap_signs_and_highlights()
    end,
}