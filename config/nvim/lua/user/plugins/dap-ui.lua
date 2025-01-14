return {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
        require("dapui").setup({
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
                        {
                            id = "scopes",
                            size = 0.25,
                        },
                        {
                            id = "breakpoints",
                            size = 0.25,
                        },
                        {
                            id = "stacks",
                            size = 0.25,
                        },
                        {
                            id = "watches",
                            size = 0.25,
                        },
                    },
                    position = "left",
                    size = 40,
                },
                {
                    elements = {
                        {
                            id = "repl",
                            size = 1.0,
                        },
                        -- {
                        --     id = "console",
                        --     size = 0.5,
                        -- },
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
        })
        local dap, dapui = require("dap"), require("dapui")
        ---@diagnostic disable-next-line: undefined-field
        local listeners = dap.listeners
        listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        vim.api.nvim_set_hl(
            0,
            "DapBreakpoint",
            { ctermbg = 0, fg = "#993939", bg = "#292E42" }
        )
        vim.api.nvim_set_hl(
            0,
            "DapLogPoint",
            { ctermbg = 0, fg = "#61afef", bg = "#292E42" }
        )
        vim.api.nvim_set_hl(
            0,
            "DapStopped",
            { ctermbg = 0, fg = "#98c379", bg = "#292E42" }
        )

        vim.fn.sign_define("DapBreakpoint", {
            text = "",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakpointCondition", {
            text = "ﳁ",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakpointRejected", {
            text = "",
            texthl = "DapBreakpoint",
            linehl = "DapBreakpoint",
            numhl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapLogPoint", {
            text = "",
            texthl = "DapLogPoint",
            linehl = "DapLogPoint",
            numhl = "DapLogPoint",
        })
        vim.fn.sign_define("DapStopped", {
            text = "",
            texthl = "DapStopped",
            linehl = "DapStopped",
            numhl = "DapStopped",
        })
    end,
}
