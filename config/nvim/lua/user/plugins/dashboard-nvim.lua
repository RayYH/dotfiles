return {
    -- "glepnir/dashboard-nvim",
    "nvimdev/dashboard-nvim",
    opts = {
        theme = "doom",
        config = {
            disable_move = true,
            header = {
                "",
                "",
                "",
                "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "",
                "--------------------------------------------------",
                "",
                "",
            },
            center = {
                {
                    icon = "󰚰  ",
                    desc = "Update Plugins          ",
                    key = "u",
                    keymap = "SPC f u",
                    action = "Lazy update",
                },

                {
                    icon = "  ",
                    desc = "Find file               ",
                    key = "f",
                    keymap = "SPC f f",
                    action = "Telescope find_files",
                },
                {
                    icon = "  ",
                    desc = "Recent files            ",
                    key = "r",
                    keymap = "SPC f r",
                    action = "Telescope oldfiles",
                },
                {
                    icon = "  ",
                    desc = "Find Word               ",
                    key = "g",
                    keymap = "SPC f g",
                    action = "Telescope live_grep",
                },
            },
            footer = { "" },
        },
        hide = { statusline = false, tabline = false, winbar = false },
    },
    init = function()
        vim.api.nvim_set_hl(0, "DashboardHeader", {
            fg = "#6272a4",
        })
        vim.api.nvim_set_hl(0, "DashboardDesc", {
            fg = "#f8f8f2",
        })
        vim.api.nvim_set_hl(0, "DashboardIcon", {
            fg = "#bd93f9",
        })
        vim.api.nvim_set_hl(0, "DashboardKey", {
            fg = "#6272a4",
        })
        vim.api.nvim_set_hl(0, "DashboardFooter", {
            fg = "#6272a4",
        })
    end,
}
